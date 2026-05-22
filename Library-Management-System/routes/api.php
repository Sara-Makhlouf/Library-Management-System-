<?php

use App\Http\Controllers\ContestController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PollController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReadingController;


use App\Http\Controllers\Api\Admin\BookController;
use App\Http\Controllers\Api\Admin\CategoryController;
use App\Http\Controllers\Api\Admin\AuthorController;
use App\Http\Controllers\Api\Admin\BillController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\TransactionController as AdminTransactionController;
use App\Http\Controllers\Api\Admin\UserController;
use App\Http\Controllers\Api\Admin\WaitingListController;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


Route::middleware('auth:sanctum')->group(function () {

    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

   
    Route::post('/reading/update-progress', [ReadingController::class, 'updateProgress']);

    Route::prefix('transactions')->group(function () {
        Route::post('/borrow', [TransactionController::class, 'borrowBook']);
        Route::post('/checkout', [TransactionController::class, 'store']);
        Route::post('/{id}/return', [TransactionController::class, 'returnBook']);
        Route::get('/late', [TransactionController::class, 'getLateTransactions']);
    });

    Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']);

    Route::post('/admin/notifications/global', [NotificationController::class, 'sendGlobalNotification']);
    
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('/mark-as-read', [NotificationController::class, 'markAsRead']);
    });

    Route::prefix('contests')->group(function () {
        Route::get('/', [ContestController::class, 'index']);
        Route::post('/{id}/join', [ContestController::class, 'join']);
        Route::post('/{id}/progress', [ContestController::class, 'updateProgress']);
    });

    Route::prefix('polls')->group(function () {
        Route::get('/', [PollController::class, 'index']);
        Route::post('/vote', [PollController::class, 'vote']);
    });

    
    Route::prefix('admin')->middleware('admin')->group(function () {

        Route::get('/dashboard-stats', [DashboardController::class, 'index']);

        Route::apiResource('books', BookController::class);

        Route::post('/categories', [CategoryController::class, 'store']);
        Route::get('/categories/list', [CategoryController::class, 'list']);
        Route::apiResource('authors', AuthorController::class);

        Route::apiResource('users', UserController::class);

        Route::get('/waiting-list', [WaitingListController::class, 'index']);
        Route::delete('/waiting-list/{id}', [WaitingListController::class, 'destroy']);

        Route::get('/transactions', [AdminTransactionController::class, 'index']);
        Route::get('/transactions/{id}', [AdminTransactionController::class, 'show']);
        Route::get('/transactions/top-borrowed', [AdminTransactionController::class, 'topBorrowedBooks']);

        Route::get('/bills', [BillController::class, 'index']);
        Route::get('/bills/{id}', [BillController::class, 'show']);
        Route::get('/bills/total-revenue', [BillController::class, 'totalRevenue']);

        Route::get('users/{id}/full-details', [UserController::class, 'getFullUserDetails']);

        Route::get('statistics/total-paid-orders', [UserController::class, 'getTotalPaidOrdersCount']);
        Route::get('statistics/total-borrows', [UserController::class, 'getTotalBorrowsCount']);
        Route::get('statistics/weekly-sales', [UserController::class, 'getWeeklySalesCount']);
        Route::get('statistics/weekly-borrows', [UserController::class, 'getWeeklyBorrowsCount']);

        Route::get('statistics/top-selling-books', [BookController::class, 'getTopSellingBooks']);
    });

});