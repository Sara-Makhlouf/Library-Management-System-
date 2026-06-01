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
            'error' => 'عذراً، حسابك مغلق حالياً بسبب تأخرك في إرجاع الكتب المستعارة.'
        ];
    }
        $currentlyBorrowed = Transaction::whereHas('bill', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
            ->where('status', 'received')
            ->where('type', 'borrow')
            ->count();


        if ($currentlyBorrowed >= $user->max_borrowing_limit) {
            return [
                'error' => "عذراً، لقد تجاوزت الحد المسموح لك وهو ({$user->max_borrowing_limit})يرجى ارجاع الكتب المستعارة اولا"
            ];
        }
        $book = \App\Models\Book::find($data['book_id']);
        if (!$book->is_available) {
            return [
                'error' => 'هذا الكتاب مستعار حاليا لشخص اخر'
            ];
        }
     return \Illuminate\Support\Facades\DB::transaction(function () use ($data, $book) {
            $transaction = Transaction::create([

            'bill_id'      => $data['bill_id'],
            'book_id'      => $data['book_id'],
            'price'        => $book->price, // سعر الاستعارة
            'delivered_at' => now(),
            'due_date'     => now()->addDays($data['days']),
            'status'       => 'received',
            'type'         => 'borrow'
        ]);

        $book->update(['is_available' => false]);

        return $transaction;
    });
    }
   public function processPurchase($data)
    {
        $book = \App\Models\Book::find($data['book_id']);
        if ($book->stock <= 0) {
            return ['error' => 'هذا الكتاب نفذت كميته من المخزن.'];
        }

        $paymentMethod = $data['payment_method'] ?? 'cash';


        if ($paymentMethod === 'points') {
           
            $pointsRequired = $book->sale_price * 100; 

            try {
        
                app(PointsService::class)->deductPoints($data['user_id'], $pointsRequired, "شراء كتاب: " . $book->title);
            } catch (\Exception $e) {
    
                return ['error' => $e->getMessage()];
            }
        }

        return \Illuminate\Support\Facades\DB::transaction(function () use ($data, $book, $paymentMethod) {
            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'book_id'      => $data['book_id'],
                'price'        => $book->sale_price,
                'delivered_at' => now(),
                'due_date'     => null,
                'status'       => 'sold',
                'type'         => 'buy',
    
            ]);

            $book->decrement('stock');

            return $transaction;
        });
    }
}
