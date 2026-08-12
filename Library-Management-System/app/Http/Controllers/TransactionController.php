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
use Illuminate\Support\Facades\DB;

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
     */
    public function store(Request $request)
    {
        $request->validate([
            'bill_id'             => 'required|exists:bills,id',
            'items'               => 'required|array',
            'items.*.book_id'     => 'required|exists:books,id',
            'items.*.action_type' => 'required|in:buy,borrow',
        ]);

        $user = Auth::user();
        $customer = Customer::where('user_id', $user->id)->first();

        DB::beginTransaction();
        try {
            $results = [];

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
                    $result = $this->transactionService->processPurchase($data);
                } else {
                    $result = $this->transactionService->processBorrow($data);
                }

                if (isset($result['error'])) {
                    DB::rollBack();
                    return response()->json(['status' => 'error', 'message' => $result['error']], 400);
                }

                $results[] = $result;
            }

            DB::commit();

            // إرسال الإشعارات بعد نجاح العملية بالكامل
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
                            // تجاوز خطأ الإشعارات
                        }
                    }
                }
            }

            return response()->json([
                'status'  => 'success',
                'message' => 'تمت العمليات بنجاح',
                'data'    => $results
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * 2. إرجاع كتاب مستعار (مع معالجة الأضرار أو التأخير والإشعار)
     */
    public function returnBook(Request $request, $id)
    {
        $transaction = Transaction::with(['book', 'user'])->findOrFail($id);

        if ($transaction->status === 'returned') {
            return response()->json(['status' => 'error', 'message' => 'هذا الكتاب تم إرجاعه مسبقاً'], 400);
        }

        $isDamaged = $request->input('is_damaged', false);
        $updatedTransaction = $this->transactionService->processReturn($transaction, $isDamaged);

        // 1. إرسال إشعار للمستعير الحالي بإرجاع الكتاب
        try {
            Notification::send(
                $transaction->user_id,
                'book_returned',
                'تم استلام الكتاب ✅',
                "تم تسجيل إرجاع كتاب ({$transaction->book->title}) بنجاح." .
                    ($updatedTransaction->extra_price > 0 ? " غرامة التأخير/الأضرار: {$updatedTransaction->extra_price} ل.س" : ''),
                ['target_screen' => 'my_borrows']
            );
        } catch (\Exception $e) {
            // تجاوز خطأ سيرفر الإشعارات
        }

        if (isset($updatedTransaction->next_user_id)) {
            try {
                Notification::send(
                    $updatedTransaction->next_user_id,
                    'waiting_list_turn',
                    'الكتاب أصبح متاحاً لك! 📚',
                    "حان دورك لاستلام كتاب ({$transaction->book->title}). تم تحويل الإعارة لحسابك بنجاح.",
                    ['target_screen' => 'my_borrows']
                );
            } catch (\Exception $e) {
                // تجاوز خطأ سيرفر الإشعارات
            }
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم إرجاع الكتاب بنجاح',
            'data'    => [
                'fine_amount' => $updatedTransaction->extra_price,
                'status'      => $updatedTransaction->status
            ]
        ]);
    }

    /**
     * 3. فحص وجلب الكتب المتأخرة وإرسال تنبيهات تلقائية للمتأخرين
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
                    $late->user_id,
                    'overdue_return',
                    'تنبيه: تأخرت في إعادة الكتاب! ⚠️',
                    "لقد تجاوزت المدة المسموحة لإعادة كتاب ({$late->book->title}). يرجى إعادته للمكتبة فوراً لتجنب الغرامات وتجميد الحساب.",
                    ['icon' => 'danger_alert', 'target_screen' => 'my_borrows', 'transaction_id' => $late->id]
                );
            } catch (\Exception $e) {
                // تجاوز خطأ الإشعارات
            }
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم فحص وإرسال التنبيهات بنجاح',
            'count'   => $lateTransactions->count(),
            'data'    => $lateTransactions
        ]);
    }

    /**
     * 4. جلب سجل العمليات للزبون الحالي مع Pagination
     */
    public function userHistory()
    {
        $user = Auth::user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'الزبون غير موجود'], 404);
        }

        $transactions = Transaction::where('user_id', $user->id)
            ->with(['book:id,title,cover,author'])
            ->latest()
            ->paginate(15);

        return response()->json([
            'status'        => 'success',
            'customer_name' => $customer->name,
            'data'          => $transactions
        ]);
    }
}
