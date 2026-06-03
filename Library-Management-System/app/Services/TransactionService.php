<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Complaint;
use App\Models\User;
use App\Models\Book;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

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

            if ($daysLate >= 7) {
                $transaction->user?->update(['is_active' => false]);
            }

            if ($daysLate >= 15) {
                if (!Complaint::where('transaction_id', $transaction->id)->exists()) {
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
        $user = User::find($data['user_id']);
        if (!$user->is_active) return ['error' => 'حسابك مغلق بسبب تأخر في إرجاع كتب.'];

        $currentlyBorrowed = Transaction::whereHas('bill', fn($q) => $q->where('user_id', $user->id))
            ->where('status', 'received')
            ->where('type', 'borrow')
            ->count();

        if ($currentlyBorrowed >= $user->max_borrowing_limit) return ['error' => "تجاوزت الحد المسموح للاستعارة."];

        $book = Book::find($data['book_id']);
        if (!$book->is_available) return ['error' => 'هذا الكتاب غير متاح حالياً.'];

        return DB::transaction(function () use ($data, $book) {
            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'book_id'      => $data['book_id'],
                'price'        => $book->price,
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
        $book = Book::find($data['book_id']);
        if ($book->stock <= 0) return ['error' => 'نفذت كمية هذا الكتاب.'];

        if (($data['payment_method'] ?? 'cash') === 'points') {
            try {
                app(PointsService::class)->deductPoints($data['user_id'], $book->sale_price * 100, "شراء: " . $book->title);
            } catch (\Exception $e) {
                return ['error' => $e->getMessage()];
            }
        }

        return DB::transaction(function () use ($data, $book) {
            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'book_id'      => $data['book_id'],
                'price'        => $book->sale_price,
                'delivered_at' => now(),
                'status'       => 'sold',
                'type'         => 'buy',
            ]);

            $book->decrement('stock');
            return $transaction;
        });
    }
}