<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Cart;
use App\Models\CartDetail;
use App\Models\Bill;
use App\Models\BillDetail;
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
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'سجل الزبون غير موجود'], 404);
        }

        $cart = Cart::with(['details.book' => function ($q) {
            $q->select('id', 'title', 'price', 'sale_price', 'cover');
        }])->where('customer_id', $customer->id)->first();

        return response()->json([
            'status' => 'success',
            'data'   => $cart ?? ['details' => [], 'total_price' => 0]
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

        $user = $request->user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'سجل الزبون غير موجود'], 404);
        }

        if ($request->type === 'borrow' && !$user->is_active) {
            return response()->json([
                'status'  => 'error',
                'message' => 'عذراً، حسابك مجمد حالياً بسبب تأخير في إرجاع الكتب ولا يمكنك الاستعارة.'
            ], 403);
        }

        $book = Book::findOrFail($request->book_id);

        if ($book->stock <= 0) {
            return response()->json(['status' => 'error', 'message' => 'عذراً، هذا الكتاب غير متوفر حالياً بالمخزون'], 422);
        }

        $cart = Cart::firstOrCreate(['customer_id' => $customer->id]);

        if ($cart->details()->where('book_id', $book->id)->exists()) {
            return response()->json(['status' => 'error', 'message' => 'هذا الكتاب موجود بالفعل في سلتك'], 422);
        }

        $price = ($request->type === 'buy') ? ($book->sale_price ?? $book->price) : $book->price;

        $cart->details()->create([
            'book_id' => $book->id,
            'price'   => $price,
            'type'    => $request->type,
            'due_at'  => ($request->type === 'borrow') ? now()->addDays($book->borrow_duration ?? 7) : null,
        ]);

        $cart->update(['total_price' => $cart->details()->sum('price')]);

        return response()->json([
            'status'  => 'success',
            'message' => 'تمت إضافة الكتاب للسلة بنجاح 📚',
            'data'    => $cart->load('details.book')
        ]);
    }

    /**
     * 3. إتمام عملية الطلب والـ Checkout
     */
    public function checkout(Request $request): JsonResponse
    {
        $request->validate([
            'payment_method'   => ['required', 'in:cash,online,points'],
            'is_delivery'      => ['required', 'boolean'],
            'delivery_address' => ['required_if:is_delivery,true', 'nullable', 'string', 'max:500'],
            'phone_number'     => ['required_if:is_delivery,true', 'nullable', 'string', 'max:20'],

            'items'            => ['required', 'array', 'min:1'],
            'items.*.book_id'  => ['required', 'exists:books,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
        ]);

        $user = $request->user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'المستخدم المتصل ليس لديه حساب عميل مرتبط به!'], 404);
        }

        if (!$user->is_active) {
            return response()->json([
                'status'  => 'error',
                'message' => 'حسابك مجمد بسبب وجود تأخيرات في إرجاع الكتب. يرجى تسوية المعاملات العالقة أولاً.'
            ], 403);
        }

        $cart = Cart::where('customer_id', $customer->id)->first();
        if (!$cart) {
            return response()->json(['status' => 'error', 'message' => 'عذراً، لا توجد سلة مشتريات لهذا المستخدم.'], 422);
        }

        $cartDetails = CartDetail::where('cart_id', $cart->id)->get()->keyBy('book_id');
        if ($cartDetails->isEmpty()) {
            return response()->json(['status' => 'error', 'message' => 'عذراً، سلة المشتريات فارغة تماماً.'], 422);
        }

        $inputItems = collect($request->items)->keyBy('book_id');

        $borrowItemsCount = 0;
        foreach ($cartDetails as $bookId => $cartDetail) {
            if ($cartDetail->type === 'borrow') {
                $itemQuantity = (int) ($inputItems[$bookId]['quantity'] ?? 1);
                $borrowItemsCount += $itemQuantity;
            }
        }

        if ($borrowItemsCount > 0) {
            $currentlyBorrowed = Transaction::where('user_id', $user->id)
                ->where('status', 'received')
                ->count();

            $maxLimit = $customer->max_borrowing_limit ?? 3;
            if (($currentlyBorrowed + $borrowItemsCount) > $maxLimit) {
                return response()->json([
                    'status'  => 'error',
                    'message' => "عذراً، إجمالي الكتب المستعارة سيتجاوز الحد المسموح لك وهو ({$maxLimit}) كتب في وقت واحد."
                ], 422);
            }
        }

        try {
            DB::beginTransaction();

            $deliveryFee = $request->is_delivery ? 5000 : 0;
            $itemsTotal = 0;
            $preparedItems = [];

            foreach ($cartDetails as $bookId => $cartDetail) {
                $book = Book::lockForUpdate()->find($bookId);

                $quantity = (int) ($inputItems[$bookId]['quantity'] ?? 1);

                if (!$book || $book->stock < $quantity) {
                    throw new \Exception("عذراً، الكمية المطلوبة ({$quantity}) من كتاب ({$book?->title}) غير متوفرة في المخزون حالياً.");
                }

                $unitPrice = $cartDetail->price ?? $book->price;
                $itemsTotal += ($unitPrice * $quantity);

                $preparedItems[] = [
                    'book'        => $book,
                    'quantity'    => $quantity,
                    'unit_price'  => $unitPrice,
                    'type'        => $cartDetail->type,
                    'due_at'      => $cartDetail->due_at ?? null,
                ];
            }

            $finalTotal = $itemsTotal + $deliveryFee;

            if ($request->payment_method === 'points') {
                $pointsNeeded = $finalTotal * 10;
                if ($customer->points_balance < $pointsNeeded) {
                    throw new \Exception("رصيد نقاطك غير كافٍ. تحتاج إلى {$pointsNeeded} نقطة لإتمام الطلب.");
                }

                $this->pointsService->deductPoints(
                    $customer->id,
                    $pointsNeeded,
                    "دفع فاتورة مشتريات"
                );
            }

            $bill = Bill::create([
                'customer_id'      => $customer->id,
                'total_price'      => $finalTotal,
                'payment_method'   => $request->payment_method,
                'status'           => 'paid',
                'is_delivery'      => $request->is_delivery,
                'delivery_fee'     => $deliveryFee,
                'delivery_address' => $request->is_delivery ? $request->delivery_address : null,
                'phone_number'     => $request->is_delivery ? $request->phone_number : null,
            ]);

            foreach ($preparedItems as $itemData) {
                $book = $itemData['book'];
                $quantity = $itemData['quantity'];
                $type = $itemData['type'];

                $book->decrement('stock', $quantity);

                BillDetail::create([
                    'bill_id'    => $bill->id,
                    'book_id'    => $book->id,
                    'quantity'   => $quantity,
                    'unit_price' => $itemData['unit_price'],
                ]);

                Transaction::create([
                    'bill_id'      => $bill->id,
                    'book_id'      => $book->id,
                    'user_id'      => $user->id,
                    'price'        => $itemData['unit_price'] * $quantity,
                    'extra_price'  => 0,
                    'type'         => $type,
                    'status'       => ($type === 'buy') ? 'sold' : 'received',
                    'delivered_at' => now(),
                    'due_date'     => $type === 'borrow' ? $itemData['due_at'] : null,
                ]);
            }

            $earnedPoints = 0;
            if ($request->payment_method !== 'points') {
                $earnedPoints = floor($itemsTotal / 1000);
                if ($earnedPoints > 0) {
                    $this->pointsService->addPoints($customer->id, $earnedPoints);
                }
            }

            CartDetail::where('cart_id', $cart->id)->delete();
            $cart->update(['total_price' => 0]);

            DB::commit();

            return response()->json([
                'status'  => 'success',
                'message' => 'تمت العملية بنجاح وتسجيل الفاتورة والمعاملات حسب اختيارك في السلة!',
                'bill_id' => $bill->id
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * 4. حذف كتاب واحد من السلة
     */
    public function removeBook(Request $request, $bookId): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'سجل الزبون غير موجود'], 404);
        }

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
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'سجل الزبون غير موجود'], 404);
        }

        $cart = Cart::where('customer_id', $customer->id)->first();

        if ($cart) {
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
            return response()->json(['status' => 'success', 'message' => 'تم تفريغ سلة المشتريات بالكامل']);
        }

        return response()->json(['status' => 'error', 'message' => 'السلة غير موجودة'], 404);
    }
}
