<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Complaint;
use App\Models\User;
use App\Models\Book;
use App\Models\Notification;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class TransactionService
{
    // نسبة الغرامة اليومية (3% من سعر الكتاب)
    protected const DAILY_FINE_RATE = 0.03;

    /**
     * معالجة إرجاع الكتاب وحساب الغرامات
     */
    public function processReturn(Transaction $transaction, $isDamaged = false)
    {
        return DB::transaction(function () use ($transaction, $isDamaged) {
            $returnedAt = now();
            $fine = 0;
            $book = $transaction->book;

            if ($isDamaged) {
                // في حال التلف، الغرامة هي سعر البيع أو سعر الإعارة
                $fine = $book->sale_price ?? $book->price;
                // soft delete للكتاب التالف بدل تعديل حقل غير موجود
                $book->delete();
            } else {
                // حساب غرامة التأخير
                if ($transaction->due_date && $returnedAt->gt($transaction->due_date)) {
                    $daysLate = (int) $returnedAt->diffInDays($transaction->due_date);
                    $fine = $daysLate * ($book->price * self::DAILY_FINE_RATE);
                }
                // إرجاع نسخة للمخزون
                $book->increment('stock');
            }

            $transaction->update([
                'returned_at' => $returnedAt,
                'extra_price' => $fine,
                'status'      => 'returned',
            ]);

            // إعادة تفعيل حساب المستخدم إذا لم يكن لديه تأخيرات أخرى
            $hasOtherLateBooks = Transaction::where('user_id', $transaction->user_id)
                ->where('status', 'received')
                ->where('due_date', '<', now())
                ->exists();

            if (!$hasOtherLateBooks) {
                $transaction->user->update(['is_active' => true]);
            }

            // إشعار أول شخص في قائمة الانتظار إن وجد
            if (!$isDamaged) {
                $nextWaiter = \App\Models\WaitingList::where('book_id', $book->id)
                    ->oldest()
                    ->first();

                if ($nextWaiter) {
                    try {
                        Notification::send(
                            $nextWaiter->customer_id,
                            'book_available',
                            'الكتاب الذي تنتظره متاح الآن! 📚',
                            "أصبح كتاب ({$book->title}) متاحاً للاستعارة، يمكنك حجزه الآن.",
                            [
                                'icon'          => 'book_open',
                                'target_screen' => 'book_details',
                                'book_id'       => $book->id,
                            ]
                        );
                    } catch (\Exception $e) {
                    }
                }
            }

            return $transaction->refresh();
        });
    }

    /**
     * فحص التأخيرات الحرجة وتجميد الحسابات تلقائياً
     */
    public function checkAndEscalateLateReturns()
    {
        $lateTransactions = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->with(['user', 'book'])
            ->get();

        foreach ($lateTransactions as $transaction) {
            $daysLate = now()->diffInDays($transaction->due_date);

            // بعد 7 أيام: تجميد الحساب
            if ($daysLate >= 7 && $transaction->user->is_active) {
                $transaction->user->update(['is_active' => false]);

                try {
                    Notification::send(
                        $transaction->user->customer->id,
                        'account_frozen',
                        'تم تجميد حسابك ⚠️',
                        "تم تجميد حسابك بسبب تأخر إرجاع كتاب ({$transaction->book->title}) لأكثر من 7 أيام.",
                        ['icon' => 'account_freeze', 'target_screen' => 'my_borrows']
                    );
                } catch (\Exception $e) {
                }
            }

            // بعد 15 يوم: اعتبار الكتاب مفقوداً وفتح شكوى
            if ($daysLate >= 15) {
                if (!Complaint::where('transaction_id', $transaction->id)->exists()) {
                    Complaint::create([
                        'transaction_id' => $transaction->id,
                        'user_id'        => $transaction->user_id,
                        'reason'         => "تأخير حرج (أكثر من 15 يوماً): تم اعتبار الكتاب مفقوداً.",
                        'total_fine'     => $transaction->book->price * 1.5,
                    ]);
                    $transaction->update(['status' => 'expired']);
                }
            }
        }
    }

    /**
     * معالجة طلب الاستعارة
     */
    public function processBorrow($data)
    {
        $user = User::with('customer')->find($data['user_id']);

        if (!$user) {
            return ['error' => 'المستخدم غير موجود.'];
        }

        if (!$user->is_active) {
            return ['error' => 'عذراً، حسابك مجمد حالياً بسبب تأخير في إرجاع الكتب.'];
        }

        $currentlyBorrowed = Transaction::where('user_id', $user->id)
            ->where('status', 'received')
            ->count();

        $maxLimit = $user->customer->max_borrowing_limit ?? 3;
        if ($currentlyBorrowed >= $maxLimit) {
            return ['error' => 'لقد وصلت للحد الأقصى من الكتب المستعارة في وقت واحد.'];
        }

        $book = Book::find($data['book_id']);

        if (!$book || $book->stock <= 0) {
            return ['error' => 'هذا الكتاب غير متاح للاستعارة حالياً.'];
        }

        return DB::transaction(function () use ($data, $book) {
            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'user_id'      => $data['user_id'],
                'book_id'      => $data['book_id'],
                'price'        => $book->price,
                'delivered_at' => now(),
                'due_date'     => now()->addDays($data['days'] ?? 7),
                'status'       => 'received',
                'type'         => 'borrow',
            ]);

            $book->decrement('stock');

            return $transaction;
        });
    }

    /**
     * معالجة طلب الشراء
     */
    public function processPurchase($data)
    {
        $book = Book::findOrFail($data['book_id']);

        if ($book->stock <= 0) {
            return ['error' => 'نفذت الكمية المتوفرة من هذا الكتاب.'];
        }

        return DB::transaction(function () use ($data, $book) {
            // إذا كان الدفع بالنقاط
            if (($data['payment_method'] ?? 'cash') === 'points') {
                $pointsNeeded = $book->sale_price * 10;
                $customer = User::find($data['user_id'])->customer;

                if ($customer->points_balance < $pointsNeeded) {
                    throw new \Exception("رصيد نقاطك غير كافٍ. تحتاج إلى {$pointsNeeded} نقطة.");
                }

                app(PointsService::class)->deductPoints(
                    $customer->id,
                    $pointsNeeded,
                    "شراء كتاب: " . $book->title
                );
            }

            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'user_id'      => $data['user_id'],
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
