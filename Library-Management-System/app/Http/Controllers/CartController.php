<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Cart;
use App\Models\Bill;
use App\Models\Transaction;
use App\Models\Notification;
use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\JsonResponse;

class CartController extends Controller
{
    protected $pointsService;

    public function __construct(PointsService $pointsService)
    {
        $this->pointsService = $pointsService;
    }

    /**
     * 1. عرض السلة الحالية للزبون
     */
    public function index(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;
        $cart = Cart::with(['details.book' => function ($q) {
            $q->select('id', 'title', 'price', 'sale_price', 'cover');
        }])->where('customer_id', $customer->id)->first();

        return response()->json([
            'status' => 'success',
            'data' => $cart ?? ['details' => [], 'total_price' => 0]
        ]);
    }

    /**
     * 2. إضافة كتاب للسلة (شراء أو استعارة)
     */
    public function addBook(Request $request): JsonResponse
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
            'type'    => ['required', 'in:buy,borrow'],
        ]);

        $customer = $request->user()->customer;
        $book = Book::findOrFail($request->book_id);

        if ($book->stock <= 0) {
            return response()->json(['status' => 'error', 'message' => 'عذراً، هذا الكتاب غير متوفر حالياً'], 422);
        }

        $cart = Cart::firstOrCreate(['customer_id' => $customer->id]);

        if ($cart->details()->where('book_id', $book->id)->exists()) {
            return response()->json(['status' => 'error', 'message' => 'هذا الكتاب موجود بالفعل في سلتك'], 422);
        }

        $price = ($request->type === 'buy') ? $book->sale_price : $book->price;

        $cart->details()->create([
            'book_id' => $book->id,
            'price'   => $price,
            'type'    => $request->type,
            'due_at'  => ($request->type === 'borrow') ? now()->addDays(7) : null,
        ]);

        $cart->update(['total_price' => $cart->details()->sum('price')]);

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إضافة الكتاب للسلة بنجاح',
            'data' => $cart->load('details.book')
        ]);
    }

    /**
     * 3. إتمام عملية الطلب والـ Checkout وتحويل السلة لفاتورة وعمليات
     */
    public function checkout(Request $request): JsonResponse
    {
        $request->validate([
            'payment_method' => ['required', 'in:cash,online'],
            'is_delivery'    => ['required', 'boolean'],
        ]);

        $user = $request->user();
        $customer = $user->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'المستخدم المتصل ليس لديه حساب عميل مرتبط به!']);
        }

        $cart = Cart::where('customer_id', $customer->id)->first();

        if (!$cart) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، لا توجد سلة مشتريات لهذا المستخدم.'
            ], 422);
        }

        $cartDetails = \App\Models\CartDetail::where('cart_id', $cart->id)->get();

        if ($cartDetails->isEmpty()) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، سلة المشتريات فارغة تماماً، لا يمكن إتمام الطلب.'
            ], 422);
        }

        try {
            DB::beginTransaction();

            $deliveryFee = $request->is_delivery ? 5000 : 0;
            $finalTotal = $cart->total_price + $deliveryFee;

            $bill = Bill::create([
                'customer_id'    => $customer->id,
                'total_price'    => $finalTotal,
                'payment_method' => $request->payment_method,
                'status'         => 'paid',
                'is_delivery'    => $request->is_delivery,
                'delivery_fee'   => $deliveryFee,
            ]);

            foreach ($cartDetails as $detail) {

                $book = \App\Models\Book::find($detail->book_id);
                if ($book && $book->stock > 0) {
                    $book->decrement('stock');
                }

                \App\Models\BillDetail::create([
                    'bill_id'    => $bill->id,
                    'book_id'    => $detail->book_id,
                    'quantity'   => 1,
                    'unit_price' => $detail->price,
                ]);

                Transaction::create([
                    'bill_id'      => $bill->id,
                    'book_id'      => $detail->book_id,
                    'user_id'      => $user->id,
                    'price'        => $detail->price,
                    'extra_price'  => 0,
                    'type'         => $detail->type,
                    'status'       => ($detail->type === 'buy') ? 'sold' : 'received',
                    'delivered_at' => now(),
                    'due_date'     => $detail->due_at,
                ]);
            }

            $earnedPoints = floor($cart->total_price / 1000);
            if ($earnedPoints > 0 && isset($this->pointsService)) {
                $this->pointsService->addPoints($customer->id, $earnedPoints);
            }

            \App\Models\CartDetail::where('cart_id', $cart->id)->delete();
            $cart->update(['total_price' => 0]);

            DB::commit();
            try {
                Notification::send(
                    $user->id,
                    'order_success',
                    'تم تأكيد طلبك بنجاح! 📖',
                    "شكراً لثقتك. تم تسجيل طلبك بمبلغ {$finalTotal} ل.س وحصلت على {$earnedPoints} نقطة مكافأة.",
                    ['icon' => 'shopping_bag', 'target_screen' => 'order_details']
                );
            } catch (\Exception $e) {
                // تخطي خطأ سيرفر الإشعارات
            }

            return response()->json([
                'status'  => 'success',
                'message' => 'تمت العملية بنجاح، وتم تسجيل الفاتورة والمعاملات في قاعدة البيانات!',
                'bill_id' => $bill->id
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status'  => 'error',
                'message' => 'حدث خطأ غير متوقع وتم التراجع عن البيانات: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 4. حذف كتاب واحد من السلة
     */
    public function removeBook(Request $request, $bookId): JsonResponse
    {
        $customer = $request->user()->customer;
        $cart = Cart::where('customer_id', $customer->id)->first();

        if ($cart) {
            $cart->details()->where('book_id', $bookId)->delete();
            $cart->update(['total_price' => $cart->details()->sum('price')]);
            return response()->json(['status' => 'success', 'message' => 'تم إزالة الكتاب من السلة']);
        }
        return response()->json(['status' => 'error', 'message' => 'السلة غير موجودة'], 404);
    }

    /**
     * 5. تفريغ السلة بالكامل
     */
    public function clear(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;
        $cart = Cart::where('customer_id', $customer->id)->first();

        if ($cart) {
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
            return response()->json(['status' => 'success', 'message' => 'تم تفريغ سلة المشتريات بالكامل']);
        }
        return response()->json(['status' => 'error', 'message' => 'السلة غير موجودة'], 404);
    }
}
