<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class BillController extends Controller
{
    use ApiResponse, NotifiesUsers;

    public function index(): JsonResponse
    {
        $bills = Bill::with('customer')
            ->latest()
            ->paginate(15);

        return $this->successResponse($bills);
    }

    public function show($id): JsonResponse
    {
        $bill = Bill::with(['customer', 'billDetails.book' => function ($q) {
            $q->withTrashed();
        }])->findOrFail($id);

        return $this->successResponse($bill);
    }

    public function totalRevenue(Request $request): JsonResponse
    {
        $total = Bill::where('status', 'paid')->sum('total_price');

        $this->notifySafe(
            $request->user()->id,
            'revenue_checked',
            'استعلام عن الإيرادات 💰',
            "تم طلب تقرير الإيرادات. المجموع الكلي للمبيعات والإعارات المدفوعة: {$total} ل.س.",
            ['icon' => 'revenue_chart', 'target_screen' => 'admin_dashboard']
        );

        return response()->json([
            'status' => 'success',
            'total_revenue' => $total
        ]);
    }

    public function deliveryRequests(Request $request)
    {
        $bills = Bill::with(['customer.user'])
            ->where('is_delivery', true)
            ->when($request->status, function ($query, $status) {
                return $query->where('delivery_status', $status);
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->successResponse($bills);
    }

    public function updateDeliveryStatus(Request $request, int $id)
    {
        $request->validate([
            'delivery_status' => 'required|in:pending,preparing,out_for_delivery,delivered'
        ]);

        $bill = Bill::with('customer.user')->findOrFail($id);

        if (!$bill->is_delivery) {
            return $this->errorResponse('هذه الفاتورة ليست طلب توصيل', 422);
        }

        $bill->update([
            'delivery_status' => $request->delivery_status
        ]);

        $this->notifySafe(
            $bill->customer->user_id,
            'delivery_update',
            'تحديث حالة الطلب 🚚',
            "تم تحديث حالة توصيل طلبك رقم (#{$bill->id}) لتصبح الآن: " . $this->translateStatus($request->delivery_status),
            ['icon' => 'delivery_truck', 'target_screen' => 'order_details', 'bill_id' => $bill->id]
        );

        return $this->successResponse($bill, 'تم تحديث حالة التوصيل بنجاح');
    }

    private function translateStatus($status)
    {
        $statuses = [
            'pending'          => 'قيد الانتظار',
            'preparing'        => 'جاري التجهيز',
            'out_for_delivery' => 'خرج للتوصيل',
            'delivered'        => 'تم التسليم بنجاح'
        ];
        return $statuses[$status] ?? $status;
    }
}
