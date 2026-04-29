<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Complaint; 
use Carbon\Carbon;

class TransactionService
{
    protected $dailyFineRate = 0.03;

    public function processReturn(Transaction $transaction, $isdamaged = false)
    {
        $returnedAt = now();
        $fine = 0;

        $bookPrice = $transaction->book->price;

        if ($isdamaged) {
            $fine = $transaction->mortgage;
        } else {
            if ($transaction->due_date && $returnedAt->gt($transaction->due_date)) {
                $daysLate = $returnedAt->diffInDays($transaction->due_date);
                $finePerDay = $bookPrice * $this->dailyFineRate;
                $fine = $daysLate * $finePerDay;
            }
        }

        $customerReturnAmount = max(0, $transaction->mortgage - $fine);

        $transaction->update([
            'returned_at'             => $returnedAt,
            'extra_price'             => $fine,
            'customer_return_amount'  => $customerReturnAmount,
            'status'                  => 'returned'
        ]);

        return $transaction;
    }

    /**
     * فحص العمليات المتأخرة جداً (أكثر من 15 يوم) وفتح شكاوى تلقائية
     */
    public function checkAndEscalateLateReturns()
    {
        // تحسين الاستعلام: جلب فقط العمليات التي مضى على تاريخ استحقاقها 15 يوم أو أكثر
        $criticalDate = now()->subDays(15);

        $lateTransactions = Transaction::where('status', 'received')
                            ->where('due_date', '<=', $criticalDate)
                            ->get();

        foreach ($lateTransactions as $transaction) {
            
            // التأكد من عدم وجود شكوى سابقة لنفس العملية
            $alreadyComplained = Complaint::where('transaction_id', $transaction->id)->exists();

            if (!$alreadyComplained) {
                // حساب الأيام بدقة للشكوى
                $daysLate = now()->diffInDays($transaction->due_date);
                $totalFine = $daysLate * ($transaction->book->price * $this->dailyFineRate);

                Complaint::create([
                    'transaction_id' => $transaction->id,
                    'user_id'        => $transaction->user->id, 
                    'reason'         => "تأخير حرج: الكتاب لم يعد منذ $daysLate يوماً",
                    'total_fine'     => $totalFine,
                ]);
                
                $transaction->update(['status' => 'expired']);
            }
        }
    }
}