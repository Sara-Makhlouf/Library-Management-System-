<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Models\Book;
use App\Models\Cart;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CartController extends Controller
{
    /**
     * عرض محتوى السلة الحالية
     */
    public function index(Request $request)
    {
        $customer = $request->user()->customer;
        $cart     = $customer->cart()->with('details.book')->first();

        if (! $cart) {
            return apiSuccess('السلة فارغة', ['items' => [], 'total_price' => 0]);
        }

        return apiSuccess('محتوى السلة', $cart);
    }

    /**
     * إضافة كتاب للسلة
     * يحسب price و mortgage و due_at من جدول books تلقائياً
     */
    public function addBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
        ]);

        $customer = $request->user()->customer;
        $book     = Book::findOrFail($request->book_id);

        // التحقق من توفر الكتاب في المخزون
        if ($book->stock <= 0) {
            return apiError('الكتاب غير متوفر حالياً', 422);
        }

        // إنشاء سلة للعميل إن لم تكن موجودة
        $cart = $customer->cart()->firstOrCreate(
            ['customer_id' => $customer->id],
            ['total_price' => 0]
        );

        // التحقق إن الكتاب مو موجود في السلة مسبقاً
        $alreadyInCart = $cart->details()->where('book_id', $book->id)->exists();
        if ($alreadyInCart) {
            return apiError('الكتاب موجود في السلة مسبقاً', 422);
        }

        // حساب due_at من borrow_duration
        $dueAt = now()->addDays($book->borrow_duration ?? 7);

        // إضافة الكتاب لتفاصيل السلة
        $cart->details()->create([
            'book_id'  => $book->id,
            'price'    => $book->price,       // من جدول books
            'mortgage' => $book->mortgage,    // من جدول books
            'due_at'   => $dueAt,
        ]);

        // تحديث المجموع
        $cart->update([
            'total_price' => $cart->details()->sum(DB::raw('price + mortgage')),
        ]);

        return apiSuccess('تم إضافة الكتاب للسلة', $cart->load('details.book'));
    }

    /**
     * حذف كتاب من السلة
     */
    public function removeBook(Request $request, Book $book)
    {
        $customer = $request->user()->customer;
        $cart     = $customer->cart;

        if (! $cart) {
            return apiError('السلة فارغة', 422);
        }

        $cart->details()->where('book_id', $book->id)->delete();

        // تحديث المجموع
        $cart->update([
            'total_price' => $cart->details()->sum(DB::raw('price + mortgage')),
        ]);

        return apiSuccess('تم حذف الكتاب من السلة');
    }

    /**
     * تفريغ السلة كاملاً
     */
    public function clear(Request $request)
    {
        $customer = $request->user()->customer;
        $cart     = $customer->cart;

        if ($cart) {
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
        }

        return apiSuccess('تم تفريغ السلة');
    }

    /**
     * إتمام عملية الدفع (Checkout)
     *
     * العملية:
     * 1. التحقق من السلة وتوفر الكتب
     * 2. إنشاء bill بحالة paid
     * 3. إنشاء bill_details لكل كتاب
     * 4. إنشاء transactions لكل كتاب
     * 5. تخفيض stock كل كتاب
     * 6. تفريغ السلة
     */
    public function checkout(Request $request)
    {
        $request->validate([
            'payment_method' => ['required', 'in:cash,online'],
        ]);

        $customer = $request->user()->customer;
        $cart     = $customer->cart()->with('details.book')->first();

        if (! $cart || $cart->details->isEmpty()) {
            return apiError('السلة فارغة', 422);
        }

        // التحقق من توفر جميع الكتب في المخزون
        foreach ($cart->details as $detail) {
            if ($detail->book->stock <= 0) {
                return apiError("الكتاب ({$detail->book->title}) غير متوفر حالياً", 422);
            }
        }

        $bill = DB::transaction(function () use ($cart, $customer, $request) {

            // 1. إنشاء الفاتورة
            $bill = Bill::create([
                'customer_id'    => $customer->id,
                'total_price'    => $cart->total_price,
                'discount_amount'=> 0,
                'status'         => 'paid',
                'payment_method' => $request->payment_method,
            ]);

            foreach ($cart->details as $detail) {
                $book = $detail->book;

                // 2. إنشاء تفاصيل الفاتورة
                $bill->details()->create([
                    'book_id'    => $book->id,
                    'quantity'   => 1,
                    'unit_price' => $detail->price + $detail->mortgage,
                ]);

                // 3. إنشاء transaction لتتبع الاستعارة
                Transaction::create([
                    'bill_id'      => $bill->id,
                    'book_id'      => $book->id,
                    'price'        => $detail->price,
                    'mortgage'     => $detail->mortgage,
                    'extra_price'  => 0,
                    'delivered_at' => now(),
                    'due_date'     => $detail->due_at,
                    'status'       => 'reserved',
                ]);

                // 4. تخفيض المخزون
                $book->decrement('stock');
            }

            // 5. تفريغ السلة
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);

            return $bill;
        });

        return apiSuccess('تم إتمام عملية الدفع بنجاح', [
            'bill_id'        => $bill->id,
            'total_price'    => $bill->total_price,
            'payment_method' => $bill->payment_method,
            'status'         => $bill->status,
        ]);
    }
}
