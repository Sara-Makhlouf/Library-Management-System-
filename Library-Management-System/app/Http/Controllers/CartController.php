<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Models\Book;
use App\Models\Cart;
use App\Models\Transaction;
use App\Models\Notification; // استدعاء الموديل الموحد هنا ✅
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

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط بملف عميل'
            ], 403);
        }

        $cart = $customer->cart()->with('details.book')->first();

        if (! $cart) {
            return response()->json([
                'status' => 'success',
                'message' => 'السلة فارغة',
                'data' => ['items' => [], 'total_price' => 0]
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'محتوى السلة',
            'data' => $cart
        ]);
    }

    /**
     * إضافة كتاب للسلة
     */
    public function addBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
        ]);

        $customer = $request->user()->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، لا يمكن للآدمن إضافة كتب للسلة'
            ], 403);
        }

        $book = Book::findOrFail($request->book_id);

        if ($book->stock <= 0) {
            return response()->json([
                'status' => 'error',
                'message' => 'الكتاب غير متوفر حالياً في المخزون'
            ], 422);
        }

        $cart = $customer->cart()->firstOrCreate(
            ['customer_id' => $customer->id],
            ['total_price' => 0]
        );

        $alreadyInCart = $cart->details()->where('book_id', $book->id)->exists();
        if ($alreadyInCart) {
            return response()->json([
                'status' => 'error',
                'message' => 'الكتاب موجود في السلة مسبقاً'
            ], 422);
        }

        $dueAt = now()->addDays($book->borrow_duration ?? 7);

        $cart->details()->create([
            'book_id'  => $book->id,
            'price'    => $book->price,
            'mortgage' => $book->mortgage,
            'due_at'   => $dueAt,
        ]);

        $cart->update([
            'total_price' => $cart->details()->sum(DB::raw('price + mortgage')),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إضافة الكتاب للسلة بنجاح',
            'data' => $cart->load('details.book')
        ]);
    }

    /**
     * حذف كتاب من السلة
     */
    public function removeBook(Request $request, Book $book)
    {
        $customer = $request->user()->customer;
        $cart     = $customer?->cart;

        if (! $cart) {
            return response()->json([
                'status' => 'error',
                'message' => 'السلة فارغة بالفعل'
            ], 422);
        }

        $cart->details()->where('book_id', $book->id)->delete();

        $cart->update([
            'total_price' => $cart->details()->sum(DB::raw('price + mortgage')),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الكتاب من السلة بنجاح'
        ]);
    }

    /**
     * تفريغ السلة كاملاً
     */
    public function clear(Request $request)
    {
        $customer = $request->user()->customer;
        $cart     = $customer?->cart;

        if ($cart) {
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تفريغ السلة بنجاح'
        ]);
    }

    /**
     * إتمام عملية الدفع (Checkout)
     */
    public function checkout(Request $request)
    {
        $request->validate([
            'payment_method' => ['required', 'in:cash,online'],
            'is_delivery'      => ['required', 'boolean'],
            'delivery_address' => ['required_if:is_delivery,true', 'string', 'max:500'],
        ]);

        $customer = $request->user()->customer;
        $cart     = $customer?->cart()->with('details.book')->first();

        if (! $cart || $cart->details->isEmpty()) {
            return response()->json([
                'status' => 'error',
                'message' => 'عملية خطأ، السلة فارغة'
            ], 422);
        }

        foreach ($cart->details as $detail) {
            if ($detail->book->stock <= 0) {
                return response()->json([
                    'status' => 'error',
                    'message' => "الكتاب ({$detail->book->title}) نفذت كميته وغير متوفر حالياً"
                ], 422);
            }
        }

        $bill = DB::transaction(function () use ($cart, $customer, $request) {
            // حساب رسوم التوصيل
            $deliveryFee = $request->is_delivery ? 5000 : 0;
            $bill = Bill::create([
                'customer_id'     => $customer->id,
                'total_price'     => $cart->total_price + $deliveryFee,
                'discount_amount'=> 0,
                'status'          => 'paid',
                'payment_method' => $request->payment_method,
                'is_delivery'     => $request->is_delivery,
                'delivery_address'=> $request->is_delivery ? $request->delivery_address : null,
                'delivery_fee'    => $deliveryFee,
                'delivery_status' => $request->is_delivery ? 'pending' : 'not_applicable',
            ]);

            foreach ($cart->details as $detail) {
                $book = $detail->book;

                $bill->details()->create([
                    'book_id'    => $book->id,
                    'quantity'   => 1,
                    'unit_price' => $detail->price + $detail->mortgage,
                ]);

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

                $book->decrement('stock');
            }

            // 🔔 استخدام الدالة الموحدة لإرسال إشعار نجاح الدفع وحجز الكتب المستعارة
            Notification::send(
                $request->user()->id,
                'checkout_success',
                'تأكيد عملية الدفع والحجز 📚💳',
                'تمت عملية الدفع بنجاح بقيمة ' . $bill->total_price . ' ل.س. تم حجز كتبك واستعارتها بنجاح، يرجى مراجعة تفاصيل الحجز للالتزام بمواعيد الإرجاع.',
                [
                    'icon' => 'receipt_success',
                    'target_screen' => 'my_loans',
                    'bill_id' => $bill->id
                ]
            );

            $cart->details()->delete();
            $cart->update(['total_price' => 0]);

            return $bill;
        });

        return response()->json([
            'status' => 'success',
            'message' => 'تم إتمام عملية الدفع بنجاح وحجز الكتب واستعارتها',
            'data' => [
                'bill_id'        => $bill->id,
                'total_price'    => $bill->total_price,
                'payment_method' => $bill->payment_method,
                'status'         => $bill->status,
            ]
        ]);
    }
}
