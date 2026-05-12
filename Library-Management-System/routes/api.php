<?php

use App\Http\Controllers\TransactionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;




// الراوتات المحمية (تتطلب تسجيل دخول)
Route::middleware('auth:sanctum')->group(function () {

    // عمليات الاستعارة والشراء (POST)
    Route::prefix('transactions')->group(function () {
        Route::post('/borrow', [TransactionController::class, 'borrowBook']); // استعارة كتاب منفرد
        Route::post('/checkout', [TransactionController::class, 'store']); // إتمام السلة (شراء واستعارة)
        Route::post('/{id}/return', [TransactionController::class, 'returnBook']); // إرجاع كتاب
    });

    // الاستعلامات والتقارير (GET)
    Route::get('/transactions/late', [TransactionController::class, 'getLateTransactions']); // المتأخرين
    Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']); // سجل المستخدم
});
