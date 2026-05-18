<?php

namespace App\Services;

use App\Models\PointsTransaction;
use App\Models\Customer;
use Illuminate\Support\Facades\DB;

class PointsService
{

    public function addPoints($customerId, $amount, $type = 'earn', $reason = null)
    {

        return DB::transaction(function () use ($customerId, $amount, $type, $reason) {


            \App\Models\PointsTransaction::create([
                'customer_id' => $customerId,
                'points_amount' => $amount,
                'transaction_type' => $type,
                'reason'         => $reason,
            ]);


            $customer = \App\Models\Customer::findOrFail($customerId);
            $customer->increment('points_balance', $amount);

            return $customer->points_balance;
        });
    }
    public function updateProgressAndEarnPoints($customerId, $bookId, $currentPage)
    {
        $book = \App\Models\Book::findOrFail($bookId);
        if ($currentPage > $book->total_pages) {
            $currentPage = $book->total->pages;
        }
        $progress = \App\Models\UserReadingProgress::firstOrCreate(
            ['coustomer_id' => $customerId, 'book_id' => $bookId],
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
                'earned' => $pointsToEarn,
                'current_page' => $currentPage,
                'message' => 'تمة إضافة النقاط بنجاح',
                'is_completed' => $currentPage == $book->total_pages
            ];
        }
        return [
            'status' => 'no_new_points',
            'earned' => 0,
            'current_page' => $currentPage,
            'message' => 'لا توجد نقاط جديدة, صفحة مقروءة مسبقاً'
        ];
    }
    public function deductPoints($customerId, $amount, $reason = null)
{
    return DB::transaction(function () use ($customerId, $amount, $reason) {
        $customer = \App\Models\Customer::findOrFail($customerId);

        
        if ($customer->points_balance < $amount) {
            throw new \Exception("عذراً، رصيدك من النقاط غير كافٍ لإتمام هذه العملية.");
        }

       
        \App\Models\PointsTransaction::create([
            'customer_id'      => $customerId,
            'points_amount'    => $amount,
            'transaction_type' => 'deduct', 
            'reason'           => $reason,
        ]);

        $customer->decrement('points_balance', $amount);

        return $customer->points_balance;
    });
}
}
