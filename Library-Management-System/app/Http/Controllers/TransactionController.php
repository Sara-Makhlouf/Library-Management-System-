<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Transaction;
use App\Models\Book;
use App\Services\TransactionService;
use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TransactionController extends Controller
{
    protected $transactionService;
    protected $pointsService;

    public function __construct(TransactionService $transactionService, PointsService $pointsService)
    {
        $this->transactionService = $transactionService;
        $this->pointsService = $pointsService;
    }

    public function returnBook(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);

        if ($transaction->status === 'returned') {
            return response()->json(['message' => 'هذا الكتاب مستلم بالفعل'], 400);
        }

        $isDamaged = $request->input('is_damaged', false);
        $updatedTransaction = $this->transactionService->processReturn($transaction, $isDamaged);

        if (isset($updatedTransaction->next_user_id)) {
            Notification::send(
                $updatedTransaction->next_user_id,
                'book_available',
                'الكتاب الذي تنتظره متاح الآن! 📚',
                "أصبح كتاب ({$transaction->book->title}) متاحاً، يمكنك استعارته الآن قبل نفاد الكمية.",
                ['icon' => 'book_open', 'target_screen' => 'book_details', 'book_id' => $transaction->book_id]
            );
        }

        return response()->json([
            'message' => 'تم ارجاع الكتاب بنجاح',
            'data' => [
                'fine' => $updatedTransaction->extra_price,
                'status' => $updatedTransaction->status
            ]
        ]);
    }

    public function borrowBook(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'required|exists:users,id',
            'book_id' => 'required|exists:books,id',
            'bill_id' => 'required|exists:bills,id',
            'days'    => 'required|integer|min:1'
        ]);

        $result = $this->transactionService->processBorrow($data);

        if (isset($result['error'])) {
            return response()->json(['message' => $result['error']], 403);
        }

        // إضافة النقاط تلقائياً عند الاستعارة
        $customer = \App\Models\User::find($data['user_id'])->customer;
        if ($customer) {
            $this->pointsService->earnPointsForBorrow($customer->id, $data['book_id']);
        }

        return response()->json([
            'message' => 'تمت الاستعارة بنجاح',
            'data' => $result
        ]);
    }

    public function getLateTransactions()
    {
        $late = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->with(['user', 'book'])
            ->get();

        foreach ($late as $lateTransaction) {
            Notification::send(
                $lateTransaction->user_id,
                'overdue_return',
                'تنبيه: تأخرت في إعادة الكتاب! ⚠️',
                "لقد تجاوزت المدة المسموحة لإعادة كتاب ({$lateTransaction->book->title}). يرجى إعادته للمكتبة فوراً.",
                ['icon' => 'danger_alert', 'target_screen' => 'my_borrows', 'transaction_id' => $lateTransaction->id]
            );
        }

        return response()->json($late);
    }

    public function userHistory($id)
    {
        $history = Transaction::whereHas('bill', function ($q) use ($id) {
            $q->where('user_id', $id);
        })->with('book')->get();

        return response()->json($history);
    }

    public function store(Request $request)
    {
        $request->validate([
            'bill_id' => 'required|exists:bills,id',
            'items'   => 'required|array',
            'items.*.book_id'     => 'required|exists:books,id',
            'items.*.action_type' => 'required|in:borrow,buy',
        ]);

        $results = [];
        $user = Auth::user();
        $customer = $user->customer;

        foreach ($request->items as $item) {
            $data = [
                'bill_id' => $request->bill_id,
                'user_id' => $user->id,
                'book_id' => $item['book_id'],
                'days'    => $item['days'] ?? 7,
                'payment_method' => $item['payment_method'] ?? 'cash',
            ];

            if ($item['action_type'] === 'buy') {
                $results[] = $this->transactionService->processPurchase($data);
                if ($customer) $this->pointsService->earnPointsForPurchase($customer->id, $item['book_id']);
            } else {
                $results[] = $this->transactionService->processBorrow($data);
                if ($customer) $this->pointsService->earnPointsForBorrow($customer->id, $item['book_id']);
            }
        }

        foreach ($results as $result) {
            if (isset($result['error'])) return response()->json(['message' => $result['error']], 400);
        }

        // إشعارات الشراء
        foreach ($request->items as $item) {
            if ($item['action_type'] === 'buy') {
                $book = Book::find($item['book_id']);
                Notification::send(
                    $user->id,
                    'purchase_success',
                    'مبارك شراء الكتاب! 🛍️',
                    "تمت عملية شراء كتاب ({$book->title}) بنجاح.",
                    ['icon' => 'bag_success', 'target_screen' => 'my_library', 'book_id' => $item['book_id']]
                );
            }
        }

        return response()->json(['message' => 'تمت العملية بنجاح', 'data' => $results]);
    }
}
