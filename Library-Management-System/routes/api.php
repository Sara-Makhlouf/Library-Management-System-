<?php

use App\Http\Controllers\NotificationController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReadingController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/reading/update-progress', [ReadingController::class, 'updateProgress']);

    Route::post('/admin/notifications/global', [NotificationController::class, 'sendGlobalNotification']);

    Route::prefix('transactions')->group(function () {
        Route::post('/borrow', [TransactionController::class, 'borrowBook']);
        Route::post('/checkout', [TransactionController::class, 'store']);
        Route::post('/{id}/return', [TransactionController::class, 'returnBook']);
        Route::get('/late', [TransactionController::class, 'getLateTransactions']);
    });

    Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']);

    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('/mark-as-read', [NotificationController::class, 'markAsRead']);
    });
});
