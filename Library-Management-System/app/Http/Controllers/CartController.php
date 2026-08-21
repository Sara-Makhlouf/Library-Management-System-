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

    public function updateQuantity(Request $request)
    {
        $request->validate([
            'cart_detail_id' => 'required|exists:cart_details,id',
            'quantity'       => 'required|integer|min:0',
        ]);

        $user = $request->user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'حساب العميل غير موجود'], 404);
        }

        $targetDetail = CartDetail::whereHas('cart', function ($q) use ($customer) {
            $q->where('customer_id', $customer->id);
        })->find($request->cart_detail_id);

        if (!$targetDetail) {
            return response()->json(['status' => 'error', 'message' => 'عنصر السلة غير موجود'], 404);
        }

        $bookId = $targetDetail->book_id;
        $type   = $targetDetail->type;
        $price  = $targetDetail->price;
        $cartId = $targetDetail->cart_id;

        $book = Book::findOrFail($bookId);

        if ($request->quantity > $book->stock) {
            return response()->json([
                'status'  => 'error',
                'message' => "عذراً، الكمية المتوفرة في المخزون حالياً هي ({$book->stock}) فقط."
            ], 422);
        }

        $currentCount = CartDetail::where('cart_id', $cartId)
            ->where('book_id', $bookId)
            ->where('type', $type)
            ->count();

        $targetQuantity = (int) $request->quantity;

        if ($targetQuantity > $currentCount) {
            $rowsToInsert = [];
            for ($i = 0; $i < ($targetQuantity - $currentCount); $i++) {
                $rowsToInsert[] = [
                    'cart_id'    => $cartId,
                    'book_id'    => $bookId,
                    'type'       => $type,
                    'price'      => $price,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            CartDetail::insert($rowsToInsert);
        } elseif ($targetQuantity < $currentCount) {

            CartDetail::where('cart_id', $cartId)
                ->where('book_id', $bookId)
                ->where('type', $type)
                ->limit($currentCount - $targetQuantity)
                ->delete();
        }

        $totalCartPrice = CartDetail::where('cart_id', $cartId)->sum('price');
        Cart::where('id', $cartId)->update(['total_price' => $totalCartPrice]);

        return response()->json([
            'status'  => 'success',
            'message' => 'تم تحديث الكمية بنجاح'
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

        $cartItems = CartDetail::where('cart_id', $cart->id)->get();

        if ($cartItems->isEmpty()) {
            return response()->json(['status' => 'error', 'message' => 'عذراً، سلة المشتريات فارغة تماماً.'], 422);
        }

        $groupedCartDetails = $cartItems->groupBy(function ($item) {
            return $item->book_id . '-' . $item->type;
        });

        $borrowItemsCount = 0;
        foreach ($groupedCartDetails as $items) {
            $firstItem = $items->first();
            if ($firstItem->type === 'borrow') {
                $borrowItemsCount += $items->count();
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

            foreach ($groupedCartDetails as $groupKey => $items) {
                $firstItem = $items->first();
                $book = Book::lockForUpdate()->find($firstItem->book_id);
                $quantity = $items->count();

                if (!$book) {
                    throw new \Exception(
                        "عذراً، الكتاب رقم ({$firstItem->book_id}) لم يعد موجوداً في المكتبة."
                    );
                }

                if ($book->stock < $quantity) {
                    throw new \Exception(
                        "عذراً، الكمية المطلوبة ({$quantity}) من كتاب ({$book->title}) غير متوفرة في المخزون حالياً. المتوفر حالياً: ({$book->stock})."
                    );
                }
                $unitPrice = $firstItem->price ?? $book->price;
                $itemsTotal += ($unitPrice * $quantity);

                $preparedItems[] = [
                    'book'       => $book,
                    'quantity'   => $quantity,
                    'unit_price' => $unitPrice,
                    'type'       => $firstItem->type,
                    'due_at'     => $firstItem->due_at ?? null,
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
