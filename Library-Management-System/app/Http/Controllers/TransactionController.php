<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\Transaction;
use App\Models\Book;
use App\Models\Customer;
use App\Services\TransactionService;
use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class TransactionController extends Controller
{
    protected $transactionService;
    protected $pointsService;

    public function __construct(TransactionService $transactionService, PointsService $pointsService)
    {
        $this->transactionService = $transactionService;
        $this->pointsService = $pointsService;
    }

    /**
     * 1. إنشاء حركة بيع أو استعارة
     *
     */
    public function store(Request $request)
    {
        $request->validate([
            'bill_id' => 'required|exists:bills,id',
            'items'   => 'required|array',
            'items.*.book_id'     => 'required|exists:books,id',
            'items.*.action_type' => 'required|in:buy,borrow',
        ]);

        $results = [];
        $user = Auth::user();

        $customer = Customer::where('user_id', $user->id)->first();

        foreach ($request->items as $item) {
            $data = [
                'bill_id'        => $request->bill_id,
                'user_id'        => $user->id,
                'book_id'        => $item['book_id'],
                'days'           => $item['days'] ?? 7,
                'payment_method' => $item['payment_method'] ?? 'cash',
                'type'           => $item['action_type'],
            ];

            if ($item['action_type'] === 'buy') {
                $results[] = $this->transactionService->processPurchase($data);
                if ($customer) {
                    $this->pointsService->earnPointsForPurchase($customer->id, $item['book_id']);
                }
            } else {
                $results[] = $this->transactionService->processBorrow($data);
                if ($customer) {
                    $this->pointsService->earnPointsForBorrow($customer->id, $item['book_id']);
                }
            }
        }

        foreach ($results as $result) {
            if (isset($result['error'])) {
                return response()->json(['message' => $result['error']], 400);
            }
        }

        foreach ($request->items as $item) {
            if ($item['action_type'] === 'buy') {
                $book = Book::find($item['book_id']);
                if ($book) {
                    try {
                        Notification::send(
                            $user->id,
                            'purchase_success',
                            'مبارك شراء الكتاب! 🛍️',
                            "تمت عملية شراء كتاب ({$book->title}) بنجاح.",
                            ['icon' => 'bag_success', 'target_screen' => 'my_library', 'book_id' => $item['book_id']]
                        );
                    } catch (\Exception $e) {
                        Log::warning('Purchase notification failed for book ' . $item['book_id'] . ': ' . $e->getMessage());
                    }
                }
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تمت العمليات بنجاح',
            'data' => $results
        ]);
    }

    /**
     * 2. إرجاع كتاب مستعار (مع معالجة الأضرار أو التأخير)
     */
    public function returnBook(Request $request, $id)
    {
        $transaction = Transaction::with('book')->findOrFail($id);

        if ($transaction->status === 'returned') {
            return response()->json(['message' => 'هذا الكتاب تم إرجاعه مسبقاً'], 400);
        }

        $isDamaged = $request->input('is_damaged', false);
        $updatedTransaction = $this->transactionService->processReturn($transaction, $isDamaged);

        if (isset($updatedTransaction->next_user_id)) {
            try {
                // بعد processReturn
                Notification::send(
                    $transaction->user->customer->id,
                    'book_returned',
                    'تم استلام الكتاب ✅',
                    "تم تسجيل إرجاع كتاب ({$transaction->book->title}) بنجاح." .
                        ($updatedTransaction->extra_price > 0 ? " غرامة التأخير: {$updatedTransaction->extra_price} ل.س" : ''),
                    ['target_screen' => 'my_borrows']
                );
            } catch (\Exception $e) {
                Log::warning('Return book notification failed: ' . $e->getMessage());
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم إرجاع الكتاب بنجاح',
            'data' => [
                'fine_amount' => $updatedTransaction->extra_price,
                'status' => $updatedTransaction->status
            ]
        ]);
    }

    /**
     * 3. فحص وجلب الكتب المتأخرة وإرسال تنبيهات تلقائية للمستعجلين
     */
    public function getLateTransactions()
    {
        $lateTransactions = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->with(['user', 'book'])
            ->get();

        foreach ($lateTransactions as $late) {
            try {
                Notification::send(
                    $late->user->customer->id,
                    'overdue_return',
                    'تنبيه: تأخرت في إعادة الكتاب! ⚠️',
                    "لقد تجاوزت المدة المسموحة لإعادة كتاب ({$late->book->title}). يرجى إعادته للمكتبة فوراً لتجنب الغرامات.",
                    ['icon' => 'danger_alert', 'target_screen' => 'my_borrows', 'transaction_id' => $late->id]
                );
            } catch (\Exception $e) {
                Log::warning('Late transaction notification failed for transaction ' . $late->id . ': ' . $e->getMessage());
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم فحص وإرسال التنبيهات بنجاح',
            'count' => $lateTransactions->count(),
            'data' => $lateTransactions
        ]);
    }

    /**
     * 4. جلب سجل العمليات للزبون الحالي
     */
    public function userHistory()
    {
        $customer = Auth::user()->customer;

        if (!$customer) {
            return response()->json(['message' => 'الزبون غير موجود'], 404);
        }

        $transactions = Transaction::whereHas('bill', function ($q) use ($customer) {
            $q->where('customer_id', $customer->id);
        })
            ->with(['book:id,title,cover'])
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'customer_name' => $customer->name,
            'count' => $transactions->count(),
            'data' => $transactions
        ]);
    }
}
