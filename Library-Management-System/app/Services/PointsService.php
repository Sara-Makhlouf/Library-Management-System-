<?php

namespace App\Services;

use App\Models\PointsTransaction;
use App\Models\Customer;
use App\Models\Book;
use App\Models\UserReadingProgress;
use Illuminate\Support\Facades\DB;

class PointsService
{
    public function addPoints($customerId, $amount, $type = 'earn', $reason = null)
    {
        return DB::transaction(function () use ($customerId, $amount, $type, $reason) {
            PointsTransaction::create([
                'customer_id' => $customerId,
                'points_amount' => $amount,
                'transaction_type' => $type,
                'reason'         => $reason,
            ]);

            $customer = Customer::findOrFail($customerId);
            $customer->increment('points_balance', $amount);

            return $customer->points_balance;
        });
    }

    public function updateProgressAndEarnPoints($customerId, $bookId, $currentPage)
    {
        $book = Book::findOrFail($bookId);
        
        
        if ($currentPage > $book->total_pages) {
            $currentPage = $book->total_pages;
        }

        
        $progress = UserReadingProgress::firstOrCreate(
            ['customer_id' => $customerId, 'book_id' => $bookId],
            ['last_page_read' => 0]
        );

        if ($currentPage > $progress->last_page_read) {
            $newPages = $currentPage - $progress->last_page_read;
            $pointsToEarn = $newPages * 10;

            $reason = "نقاط مقابل قراءة صفحات من كتاب: " . $book->title;

            $this->addPoints($customerId, $pointsToEarn, 'earn', $reason);
            
            $progress->update([
                'last_page_read' => $currentPage
            ]);


            return [
                'points_earned' => $pointsToEarn, 
                'current_page' => $currentPage,
                'message' => 'تم إضافة النقاط بنجاح',
                'is_completed' => $currentPage == $book->total_pages
            ];
        }

        return [
            'status' => 'no_new_points',
            'points_earned' => 0,
            'current_page' => $currentPage,
            'message' => 'لا توجد نقاط جديدة، صفحة مقروءة مسبقاً'
        ];
    }

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
            \App\Models\Notification::send(
            $customerId,
            'points_deducted', 
            'تم خصم نقاط من رصيدك 📉',
            "تم خصم {$amount} نقطة من محفظتك. السبب: " . ($reason ?? 'إجراء عملية في التطبيق.'),
            [
                'icon' => 'points_minus',
                'target_screen' => 'wallet',
                'deducted_amount' => $amount
            ]
        );

            return $customer->points_balance;
        });
    }
}