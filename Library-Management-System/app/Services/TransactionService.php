<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Complaint;
use App\Models\User;
use App\Models\Book;
use App\Models\Notification;
use App\Models\WaitingList;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Exception;

class TransactionService
{
    protected const DAILY_FINE_RATE = 0.03;

    /**
     * معالجة إرجاع الكتاب وحساب الغرامات + تنبيه قائمة الانتظار
     */
    public function processReturn(Transaction $transaction, bool $isDamaged = false)
    {
        return DB::transaction(function () use ($transaction, $isDamaged) {
            $returnedAt = now();
            $fine = 0;

            $book = Book::withTrashed()->lockForUpdate()->find($transaction->book_id);

            if (!$book) {
                throw new Exception("الكتاب غير موجود.");
            }

            if ($isDamaged) {
                $fine = $book->sale_price ?? $book->price;

                $book->delete();

                WaitingList::where('book_id', $book->id)->delete();
            } else {
                if ($transaction->due_date && $returnedAt->gt($transaction->due_date)) {
                    $dueDate = Carbon::parse($transaction->due_date);
                    $daysLate = max(1, (int) $dueDate->diffInDays($returnedAt));
                    $fine = round($daysLate * ($book->price * self::DAILY_FINE_RATE), 2);
                }

                $book->increment('stock');
            }

            $transaction->update([
                'returned_at' => $returnedAt,
                'extra_price' => $fine,
                'status'      => 'returned',
            ]);

            $hasOtherLateBooks = Transaction::where('user_id', $transaction->user_id)
                ->where('status', 'received')
                ->where('due_date', '<', now())
                ->where('id', '!=', $transaction->id)
                ->exists();

            if (!$hasOtherLateBooks && $transaction->user && !$transaction->user->is_active) {
                $transaction->user->update(['is_active' => true]);
            }

            if (!$isDamaged) {
                $nextWaiter = WaitingList::where('book_id', $book->id)
                    ->oldest()
                    ->lockForUpdate()
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
                        $nextWaiter->delete();
                    } catch (Exception $e) {
                        logger()->error("فشل إرسال إشعار قائمة الانتظار: " . $e->getMessage());
                    }
                }
            }

            return $transaction->refresh();
        });
    }

    /**
     * فحص التأخيرات الحرجة وتجميد الحسابات تلقائياً (تُشغل عبر Scheduled Job)
     */
    public function checkAndEscalateLateReturns()
    {
        $lateTransactions = Transaction::where('status', 'received')
            ->where('due_date', '<', now())
            ->with(['user.customer', 'book'])
            ->get();

        foreach ($lateTransactions as $transaction) {
            $dueDate = Carbon::parse($transaction->due_date);
            $daysLate = (int) $dueDate->diffInDays(now());

            // بعد 7 أيام: تجميد الحساب
            if ($daysLate >= 7 && $transaction->user && $transaction->user->is_active) {
                $transaction->user->update(['is_active' => false]);

                try {
                    if ($transaction->user->customer) {
                        Notification::send(
                            $transaction->user->customer->id,
                            'account_frozen',
                            'تم تجميد حسابك ⚠️',
                            "تم تجميد حسابك بسبب تأخر إرجاع كتاب ({$transaction->book?->title}) لأكثر من 7 أيام.",
                            ['icon' => 'account_freeze', 'target_screen' => 'my_borrows']
                        );
                    }
                } catch (Exception $e) {
                    logger()->error("فشل إرسال إشعار تجميد الحساب: " . $e->getMessage());
                }
            }

            // بعد 15 يوم: اعتبار الكتاب مفقوداً وفتح شكوى
            if ($daysLate >= 15) {
                if (!Complaint::where('transaction_id', $transaction->id)->exists()) {
                    Complaint::create([
                        'transaction_id' => $transaction->id,
                        'user_id'        => $transaction->user_id,
                        'reason'         => "تأخير حرج (أكثر من 15 يوماً): تم اعتبار الكتاب مفقوداً.",
                        'total_fine'     => ($transaction->book?->price ?? 0) * 1.5,
                    ]);

                    $transaction->update(['status' => 'expired']);
                }
            }
        }
    }

    /**
     * معالجة طلب الاستعارة
     */
    public function processBorrow(array $data)
    {
        $user = User::with('customer')->find($data['user_id']);

        if (!$user) {
            throw new Exception('المستخدم غير موجود.');
        }

        if (!$user->is_active) {
            throw new Exception('عذراً، حسابك مجمد حالياً بسبب تأخير في إرجاع الكتب.');
        }

        $currentlyBorrowed = Transaction::where('user_id', $user->id)
            ->where('status', 'received')
            ->count();

        $maxLimit = $user->customer->max_borrowing_limit ?? 3;
        if ($currentlyBorrowed >= $maxLimit) {
            throw new Exception('لقد وصلت للحد الأقصى من الكتب المستعارة في وقت واحد.');
        }

        return DB::transaction(function () use ($data) {
            $book = Book::lockForUpdate()->find($data['book_id']);

            if (!$book || $book->stock <= 0) {
                throw new Exception('هذا الكتاب غير متاح للاستعارة حالياً.');
            }

            $transaction = Transaction::create([
                'bill_id'      => $data['bill_id'],
                'user_id'      => $data['user_id'],
                'book_id'      => $data['book_id'],
                'price'        => $book->price,
                'delivered_at' => now(),
                'due_date'     => now()->addDays($data['days'] ?? $book->borrow_duration ?? 7),
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
    public function processPurchase(array $data)
    {
        return DB::transaction(function () use ($data) {
            $book = Book::lockForUpdate()->find($data['book_id']);

            if (!$book || $book->stock <= 0) {
                throw new Exception('نفدت الكمية المتوفرة من هذا الكتاب.');
            }

            if (($data['payment_method'] ?? 'cash') === 'points') {
                $pointsNeeded = ($book->sale_price ?? $book->price) * 10;
                $user = User::with('customer')->find($data['user_id']);
                $customer = $user?->customer;

                if (!$customer || $customer->points_balance < $pointsNeeded) {
                    throw new Exception("رصيد نقاطك غير كافٍ. تحتاج إلى {$pointsNeeded} نقطة.");
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
                'price'        => $book->sale_price ?? $book->price,
                'delivered_at' => now(),
                'status'       => 'sold',
                'type'         => 'buy',
            ]);

            $book->decrement('stock');

            return $transaction;
        });
    }
}
