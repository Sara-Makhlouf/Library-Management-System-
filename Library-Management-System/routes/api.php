<?php

use App\Http\Controllers\TransactionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/transactions/{id}/return', [TransactionController::class, 'returnBook']);