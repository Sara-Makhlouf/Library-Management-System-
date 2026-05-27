<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Models\Notification; 
use Illuminate\Http\Request; 
use Illuminate\Http\JsonResponse;

class BillController extends Controller
{
    /**
     * عرض كل الفواتير
     */
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

    /**
     * عرض تفاصيل فاتورة محددة
     */
    public function show($id): JsonResponse
    {
        $bill = Bill::with(['customer', 'books'])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $bill
        ]);
    }

    /**
     * حساب إجمالي الإيرادات
     */
    public function totalRevenue(Request $request): JsonResponse
    {
        $total = Bill::where('status', 'paid')->sum('total_price');

        // 🔔 إرسال الإشعار الموحد باستخدام الـ ID الآمن من الـ Token
        try {
            Notification::send(
                $request->user()->id,
                'revenue_checked',
                'استعلام عن الإيرادات 💰',
                "تم طلب تقرير إجمالي الإيرادات، والمجموع الحالي هو: {$total} ل.س.",
                [
                    'icon' => 'revenue_chart',
                    'target_screen' => 'admin_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز أي خطأ طارئ لضمان استقرار العملية
        }

        return response()->json([
            'status' => 'success',
            'total_revenue' => $total
        ]);
    }
}