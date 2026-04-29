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

        $transaction = Transaction::findOrFile($id);
        if ($transaction->status ===  'returned') {
            return response()->json([
                'message' => 'هذا الكتاب مستلم بالفعل'
            ], 400);
        }
        $isDamaged = $request->input('is_damaged', false);
        $updatedTransaction = $this->transactionService->processReturn($transaction, $isDamaged);

        return response()->json([
            'message' => 'تم ارجاع الكتاب بنجاح',
            'date' => [
                'fine' => $updatedTransaction->extra_price,
                'returned_amount' => $updatedTransaction->customer_return_amount,
                'status' => $updatedTransaction->status

            ]

        ]);
    }
}
