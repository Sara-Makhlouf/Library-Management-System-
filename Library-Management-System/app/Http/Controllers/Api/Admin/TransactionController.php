<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;
class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $transactions = Transaction::with(['customer', 'book'])
            ->when($request->type, function ($query, $type) {
                return $query->where('type', $type);
            })
            ->latest()
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }

    public function show($id): JsonResponse
    {
        $transaction = Transaction::with(['customer', 'book'])->findOrFail($id);
        return response()->json([
            'status' => 'success',
            'data' => $transaction
        ]);
    }

 public function topBorrowedBooks(): JsonResponse
{
    $report = Transaction::whereIn('status', ['received', 'returned'])
        ->select('book_id', DB::raw('count(*) as total_borrows'))
        ->with('book:id,title')
        ->groupBy('book_id')
        ->orderByDesc('total_borrows')
        ->take(5)
        ->get();

    return response()->json([
        'status' => 'success',
        'data' => $report
    ]);
}

public function getTotalBorrowsCount()
{
    $allTransactions = \App\Models\Transaction::count();
    $returnedBorrows = \App\Models\Transaction::where('status', 'returned')->count();
    $activeBorrows = \App\Models\Transaction::where('status', 'received')->count();
    $expiredBorrows = \App\Models\Transaction::where('status', 'expired')->count();

    return response()->json([
        'status' => 'success',
        'data' => [
            'total_count' => $allTransactions,
            'details' => [
                'returned' => $returnedBorrows,
                'active' => $activeBorrows,
                'expired' => $expiredBorrows,
            ],
            'info' => 'تم حساب الإحصائيات بناءً على حالات جدول العمليات'
        ]
    ]);
}

public function getWeeklySalesCount()
{
    $startOfWeek = Carbon::now()->startOfWeek();
    $endOfWeek = Carbon::now()->endOfWeek();

    $weeklySales = \App\Models\Bill::where('status', 'paid')
        ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
        ->count();

    return response()->json([
        'status' => 'success',
        'report_type' => 'Weekly Sales',
        'period' => [
            'from' => $startOfWeek->toDateString(),
            'to' => $endOfWeek->toDateString()
        ],
        'total_count' => $weeklySales
    ]);
}

public function getWeeklyBorrowsCount()
{
    $startOfWeek = Carbon::now()->startOfWeek();
    $endOfWeek = Carbon::now()->endOfWeek();

    $weeklyBorrows = \App\Models\Transaction::whereBetween('created_at', [$startOfWeek, $endOfWeek])
        ->count();

    return response()->json([
        'status' => 'success',
        'report_type' => 'Weekly Borrows',
        'period' => [
            'from' => $startOfWeek->toDateString(),
            'to' => $endOfWeek->toDateString()
        ],
        'total_count' => $weeklyBorrows
    ]);
}
}
