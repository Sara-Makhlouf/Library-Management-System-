<?php

use App\Http\Controllers\TransactionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// 1. رابط بدء الاستعارة (الإضافة)
// هذا الرابط الذي ينشئ العملية لأول مرة عند خروج الكتاب من المكتبة
Route::post('/transactions/borrow', [TransactionController::class, 'borrowBook']);

// 2. رابط إرجاع الكتاب (الذي تملكه أنت حالياً)
Route::post('/transactions/{id}/return', [TransactionController::class, 'returnBook']);

// 3. رابط عرض العمليات المتأخرة (للمراقبة)
// لمتابعة من هم في "المراحل الأربعة" ومن تم تجميد حسابهم
Route::get('/transactions/late', [TransactionController::class, 'getLateTransactions']);

// 4. رابط عرض تاريخ استعارات مستخدم (Profile)
Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']);