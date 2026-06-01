<?php

namespace App\Services;

use App\Models\PointsTransaction;
use App\Models\Customer;
use App\Models\Book;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;

class PointsService
{
    /**
     * الدالة الأساسية لإضافة نقاط العميل وتسجيل الحركات مع إرسال إشعار تلقائي
     */
    public function addPoints($customerId, $amount, $type = 'earn', $reason = null)
    {
        return DB::transaction(function () use ($customerId, $amount, $type, $reason) {
            PointsTransaction::create([
                'customer_id'      => $customerId,
                'points_amount'    => $amount,
                'transaction_type' => $type,
                'reason'           => $reason,
            ]);

            $customer = Customer::findOrFail($customerId);
            $customer->increment('points_balance', $amount);

            //  إرسال إشعار موحد فوري للعميل عند كسب النقاط تلقائياً
            try {
                Notification::send(
                    $customer->user_id, // جلب معرف الـ User المرتبط بالزبون
                    'points_earned',
                    'ربحت نقاطاً جديدة! 🎉✨',
                    "تهانينا، تم إضافة {$amount} نقطة إلى رصيدك. السبب: {$reason}. رصيدك الإجمالي الحالي هو: {$customer->points_balance} نقطة.",
                    [
                        'icon' => 'points_bonus',
                        'target_screen' => 'profile',
                        'earned_amount' => $amount
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز خطأ الإشعار لضمان استقرار المعاملة المالية
            }

            return $customer->points_balance;
        });
    }

    /**
     * 1. منح نقاط عند تسجيل الدخول الناجح (نقطة واحدة)
     */
    public function earnPointsForLogin($customerId)
    {
        $points = 1;
        $reason = "مكافأة تسجيل الدخول اليومي للتطبيق 🔑";
        
        return $this->addPoints($customerId, $points, 'earn', $reason);
    }

    /**
     * 2. منح نقاط عند استعارة كتاب (5 نقاط)
     */
    public function earnPointsForBorrow($customerId, $bookId)
    {
        $book = Book::find($bookId);
        $bookTitle = $book->title ?? 'كتاب متميز';
        
        $points = 5;
        $reason = "مكافأة استعارة كتاب من المكتبة ({$bookTitle}) 📚";

        return $this->addPoints($customerId, $points, 'earn', $reason);
    }

    /**
     * 3. منح نقاط عند شراء كتاب (10 نقاط)
     */
    public function earnPointsForPurchase($customerId, $bookId)
    {
        $book = Book::find($bookId);
        $bookTitle = $book->title ?? 'كتاب متميز';

        $points = 10;
        $reason = "مكافأة شراء كتاب وامتلاكه نهائياً ({$bookTitle}) 💰";

        return $this->addPoints($customerId, $points, 'earn', $reason);
    }

    /**
     * دالة خصم النقاط من رصيد العميل عند الشراء بالنقاط أو الغرامات
     */
    public function deductPoints($customerId, $amount, $reason = null)
    {
        return DB::transaction(function () use ($customerId, $amount, $reason) {
            $customer = Customer::findOrFail($customerId);

            if ($customer->points_balance < $amount) {
                throw new \Exception("عذراً، رصيدك من النقاط غير كافٍ لإتمام هذه العملية.");
            }

            PointsTransaction::create([
                'customer_id'      => $customerId,
                'points_amount'    => $amount,
                'transaction_type' => 'deduct', 
                'reason'           => $reason,
            ]);

            $customer->decrement('points_balance', $amount);

            //  إرسال إشعار موحد عند خصم نقاط
            try {
                Notification::send(
                    $customer->user_id,
                    'points_deducted', 
                    'تم خصم نقاط من رصيدك 📉',
                    "تم خصم {$amount} نقطة من محفظتك. السبب: " . ($reason ?? 'إجراء عملية في التطبيق.'),
                    [
                        'icon' => 'points_minus',
                        'target_screen' => 'wallet',
                        'deducted_amount' => $amount
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز الخطأ
            }

            return $customer->points_balance;
        });
    }
}