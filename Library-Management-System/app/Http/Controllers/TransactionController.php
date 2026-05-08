<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use App\Services\TransactionService;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function returnBook(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);

        if ($transaction->status === 'returned') {
            return response()->json([
                'message' => 'هذا الكتاب مستلم بالفعل'
            ], 400);
        }

        $isDamaged = $request->input('is_damaged', false);
        $updatedTransaction = $this->transactionService->processReturn($transaction, $isDamaged);

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
            'days' => 'required|integer|min:1'
        ]);
        $result = $this->transactionService->processBorrow($data);
        if (isset($result['error'])) {
            return response()->json(['message' => $result['error']], 403);
        }
        return response()->json([
            'message' => 'تمت الأستعارة بنجاح',
            'data' => $result
        ]);
    }
    public function getLateTransactions()
    {
        $late = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->with(['user', 'book'])
            ->get();

        return response()->json($late);
    }
    public function userHistory($id)
    {
        $history = Transaction::whereHas('bill', function ($q) use ($id) {
            $q->where('user_id', $id);
        })->with('book')->get();

        return response()->json($history);
    }
}
