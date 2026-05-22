<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use Illuminate\Http\JsonResponse;

class BillController extends Controller
{
    // عرض كل الفواتير

    public function index(): JsonResponse
    {
        $bills = Bill::with('customer')
            ->latest()
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $bills
        ]);
    }

    // عرض تفاصيل فاتورة محددة

    public function show($id): JsonResponse
    {
        $bill = Bill::with(['customer', 'books'])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $bill
        ]);
    }

public function totalRevenue(): JsonResponse
{
    $total = Bill::where('status', 'paid')->sum('total_price');

    return response()->json([
        'status' => 'success',
        'total_revenue' => $total
    ]);
}
}
