<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CustomerController;

// ==================== Public Routes ====================

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// ← top-borrowed قبل {book} مهم جداً
Route::get('/books/top-borrowed', [BookController::class, 'topBorrowed']);
Route::get('/books',              [BookController::class, 'index']);
Route::get('/books/{book}',       [BookController::class, 'show']);

// ==================== Protected Routes ====================

Route::middleware('auth:sanctum')->group(function () {

    // --- Auth ---
    Route::post('/logout',          [AuthController::class, 'logout']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

    // --- الملف الشخصي ---
    Route::get('/customer', [CustomerController::class, 'show']);
    Route::put('/customer', [CustomerController::class, 'update']);

    // --- السلة ---
    Route::get('/cart',                  [CartController::class, 'index']);
    Route::post('/cart/add',             [CartController::class, 'addBook']);
    Route::delete('/cart/remove/{book}', [CartController::class, 'removeBook']);
    Route::delete('/cart/clear',         [CartController::class, 'clear']);
    Route::post('/cart/checkout',        [CartController::class, 'checkout']);

    // --- التقييم ---
    Route::post('/books/rate', [BookController::class, 'rateBook']);
});