<?php

namespace App\Services;

use App\Models\PointsTransaction;
use App\Models\Customer;
use App\Models\Book;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PointsService
{
    /**
     * الدالة الأساسية لإضافة نقاط العميل وتسجيل الحركات
     */
    public function addPoints($customerId, $amount, $type = 'earn', $reason = null)
    {
        if ($amount <= 0) return 0;

        return DB::transaction(function () use ($customerId, $amount, $type, $reason) {
            $customer = Customer::lockForUpdate()->findOrFail($customerId);

            PointsTransaction::create([
                'customer_id'      => $customerId,
                'points_amount'    => $amount,
                'transaction_type' => $type,
                'reason'           => $reason,
            ]);

            $customer->increment('points_balance', $amount);

            // إرسال إشعار فوري
            try {
                Notification::send(
                    $customerId,
                    'points_earned',
                    'ربحت نقاطاً جديدة! 🎉✨',
                    "تهانينا، تم إضافة {$amount} نقطة إلى رصيدك. رصيدك الإجمالي الحالي هو: {$customer->points_balance} نقطة.",
                    [
                        'icon' => 'points_bonus',
                        'target_screen' => 'profile',
                        'earned_amount' => $amount
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز الخطأ لضمان استقرار العملية المالية
            }

            return $customer->points_balance;
        });
    }

    /**
     * 1. منح نقاط تسجيل الدخول (مرة واحدة يومياً فقط)
     */
    public function earnPointsForLogin($customerId)
    {
        $alreadyEarnedToday = PointsTransaction::where('customer_id', $customerId)
            ->where('reason', 'like', 'مكافأة تسجيل الدخول اليومي%')
            ->whereDate('created_at', Carbon::today())
            ->exists();

        if ($alreadyEarnedToday) {
            return false;
        }

        return $this->addPoints($customerId, 1, 'earn', "مكافأة تسجيل الدخول اليومي للتطبيق 🔑");
    }

    /**
     * 2. منح نقاط عند استعارة كتاب
     */
    public function earnPointsForBorrow($customerId, $bookId)
    {
        $book = Book::find($bookId);
        $reason = "مكافأة استعارة كتاب: " . ($book->title ?? 'كتاب متميز') . " 📚";
        return $this->addPoints($customerId, 5, 'earn', $reason);
    }

    /**
     * 3. منح نقاط عند شراء كتاب
     */
    public function earnPointsForPurchase($customerId, $bookId)
    {
        $book = Book::find($bookId);
        $reason = "مكافأة شراء كتاب: " . ($book->title ?? 'كتاب متميز') . " 💰";
        return $this->addPoints($customerId, 10, 'earn', $reason);
    }

    /**
     * دالة خصم النقاط (عند الشراء بالنقاط أو الغرامات)
     */
    public function deductPoints($customerId, $amount, $reason = null)
    {
        if ($amount <= 0) return 0;

        return DB::transaction(function () use ($customerId, $amount, $reason) {
            $customer = Customer::lockForUpdate()->findOrFail($customerId);

            if ($customer->points_balance < $amount) {
                throw new \Exception("عذراً، رصيدك من النقاط غير كافٍ.");
            }

            PointsTransaction::create([
                'customer_id'      => $customerId,
                'points_amount'    => $amount,
                'transaction_type' => 'deduct',
                'reason'           => $reason,
            ]);

            $customer->decrement('points_balance', $amount);

            try {
                Notification::send(
                    $customer->id,
                    'points_deducted',
                    'تم استخدام نقاط من رصيدك 📉',
                    "تم خصم {$amount} نقطة من محفظتك. السبب: " . ($reason ?? 'إجراء عملية في التطبيق.'),
                    ['icon' => 'points_minus', 'target_screen' => 'wallet']
                );
            } catch (\Exception $e) {
            }

            return $customer->points_balance;
        });
    }
}
