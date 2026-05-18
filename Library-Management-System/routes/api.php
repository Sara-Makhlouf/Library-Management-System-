<?php

use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReadingController; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


Route::middleware('auth:sanctum')->group(function () {

    // أولاً: نظام القراءة الإلكترونية وكسب النقاط 📖
    Route::post('/reading/update-progress', [ReadingController::class, 'updateProgress']);

    Route::prefix('transactions')->group(function () {
        Route::post('/borrow', [TransactionController::class, 'borrowBook']); // استعارة كتاب منفرد
        Route::post('/checkout', [TransactionController::class, 'store']); // إتمام السلة (شراء واستعارة)
        Route::post('/{id}/return', [TransactionController::class, 'returnBook']); // إرجاع كتاب
    
        Route::get('/late', [TransactionController::class, 'getLateTransactions']); // المتأخرين (تم نقلها داخل الـ prefix لتناسق الرابط)
    });

   
    Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']); 
});