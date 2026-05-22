
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Admin\BookController;
use App\Http\Controllers\Api\Admin\CategoryController;
use App\Http\Controllers\Api\Admin\AuthorController;
use App\Http\Controllers\Api\Admin\BillController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\TransactionController;
use App\Http\Controllers\Api\Admin\UserController;
use App\Http\Controllers\Api\Admin\WaitingListController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

   Route::middleware('auth:sanctum')->group(function () {
   Route::prefix('admin')->middleware('admin')->group(function () {

    Route::get('/dashboard-stats', [DashboardController::class, 'index']);

    Route::apiResource('books', BookController::class);

    Route::post('/categories', [CategoryController::class, 'store']);
    Route::get('/categories/list', [CategoryController::class, 'list']);
    Route::apiResource('authors', AuthorController::class);

    Route::apiResource('users', UserController::class);

    Route::get('/waiting-list', [WaitingListController::class, 'index']);
    Route::delete('/waiting-list/{id}', [WaitingListController::class, 'destroy']);

    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::get('/transactions/{id}', [TransactionController::class, 'show']);
    Route::get('/transactions/top-borrowed', [TransactionController::class, 'topBorrowedBooks']);

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
