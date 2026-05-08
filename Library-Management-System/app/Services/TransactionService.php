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
            $fine = $bookPrice;
            $transaction->book->update(['status' => 'damaged', 'is_available' => false]);
        } else {
            if ($transaction->due_date && $returnedAt->gt($transaction->due_date)) {
                $daysLate = $returnedAt->diffInDays($transaction->due_date);
                $fine = $daysLate * ($bookPrice * $this->dailyFineRate);
            }
            $transaction->book->update(['status' => 'available', 'is_available' => true]);
        }

        $transaction->update([
            'returned_at' => $returnedAt,
            'extra_price' => $fine,
            'status'      => 'returned'
        ]);

        if ($transaction->user) {
            $transaction->user->update(['is_active' => true]);
        }

        return $transaction;
    }

    public function checkAndEscalateLateReturns()
    {
        $lateTransactions = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->get();

        foreach ($lateTransactions as $transaction) {
            $daysLate = now()->diffInDays($transaction->due_date);

            // المرحلة 1: تذكير (من يوم إلى 7 أيام)
            if ($daysLate >= 1 && $daysLate < 7) {
                // منطق الإشعارات يوضع هنا لاحقاً
            }

            // المرحلة 2 و 3: إيقاف الحساب (بعد 7 أيام تأخير)
            if ($daysLate >= 7) {
                if ($transaction->user) {
                    $transaction->user->update(['is_active' => false]);
                }
            }

            // المرحلة 4: اعتبار الكتاب مفقود وفتح شكوى (بعد 15 يوم)
            if ($daysLate >= 15) {
                $alreadyComplained = Complaint::where('transaction_id', $transaction->id)->exists();

                if (!$alreadyComplained) {
                    Complaint::create([
                        'transaction_id' => $transaction->id,
                        'user_id'        => $transaction->user->id,
                        'reason'         => "تأخير حرج: الكتاب مفقود لتجاوزه 15 يوماً",
                        'total_fine'     => $transaction->book->price,
                    ]);

                    $transaction->update(['status' => 'expired']);
                }
            }
        }
    }
    public function processBorrow($data)
    {
        $user = \App\Models\User::find($data['user_id']);
        if (!$user->is_active) {
            return [
                'error' => 'حسابك معلق بسبب تأخير سابق. يرجى إعادة الكتب المتأخرة أولاً'
            ];
        }
        $book = \App\Models\Book::find($data['book_id']);
        if (!$book->is_available) {
            return [
                'error' => 'هذا الكتاب مستعار حاليا لشخص اخر'
            ];
        }
        $transaction = Transaction::created([

            'bill_id'      => $data['bill_id'],
            'book_id'      => $data['book_id'],
            'price'        => $book->price, // سعر الاستعارة
            'delivered_at' => now(),
            'due_date'     => now()->addDays($data['days']),
            'status'       => 'received'
        ]);
    }
}
