<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    /**
     * عرض قائمة العملاء مع البحث والفلترة
     */
    public function index(Request $request): JsonResponse
    {
        $users = User::has('customer')
            ->with('customer')
            ->when($request->search, function ($query, $search) {
                $query->where('email', 'like', "%{$search}%")
                    ->orWhereHas('customer', function ($q) use ($search) {
                        $q->where('name', 'like', "%{$search}%")
                            ->orWhere('phone', 'like', "%{$search}%");
                    });
            })
            ->latest()
            ->paginate(10);

        return response()->json([
            'status' => 'success',
            'data' => $users
        ]);
    }

    /**
     * عرض تفاصيل حساب مستخدم واحد
     */
    public function show($id): JsonResponse
    {
        $user = User::with(['customer' => function ($q) {
            $q->withCount(['bills', 'transactions']);
        }])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $user
        ]);
    }

    /**
     * حذف حساب مستخدم (إدارة الأدمن)
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = User::with('customer')->findOrFail($id);
        $customerName = $user->customer->name ?? 'مستخدم غير معروف';

        $user->delete();

        try {
            Notification::send(
                $request->user()->id,
                'user_deleted',
                'حذف حساب مستخدم ⚠️',
                "تم حذف حساب المستخدم ({$customerName}) وجميع بياناته بنجاح.",
                [
                    'icon' => 'user_delete',
                    'target_screen' => 'users_dashboard'
                ]
            );
        } catch (\Exception $e) {
            Log::warning('User deletion notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف المستخدم بنجاح'
        ]);
    }

    /**
     * التقرير المالي والنشاط التفصيلي للعميل
     */
    public function getFullUserDetails(Request $request, $id)
    {
        $customer = Customer::find($id);

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'الزبون غير موجود'], 404);
        }

        $borrowedBooksCount = $customer->transactions()
            ->whereIn('transactions.status', ['borrowed', 'returned'])
            ->count();

        $purchasedBooksCount = \App\Models\BillDetail::whereHas('bill', function ($q) use ($id) {
            $q->where('customer_id', $id)->where('status', 'paid');
        })->sum('quantity');

        $totalExtraFines = $customer->transactions()->sum('extra_price');

        $totalPayments = $customer->bills()
            ->where('status', 'paid')
            ->sum('total_price');

        try {
            Notification::send(
                $request->user()->id,
                'user_report_viewed',
                'استعراض ملف العميل المالي 👤',
                "تم جلب التقرير المالي الشامل للعميل ({$customer->name}).",
                [
                    'icon' => 'user_analytics',
                    'target_screen' => 'user_details',
                    'customer_id' => $customer->id
                ]
            );
        } catch (\Exception $e) {
            Log::warning('User report notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'profile' => [
                    'name' => $customer->name,
                    'phone' => $customer->phone,
                    'points' => $customer->points_balance,
                    'member_type' => $customer->points_balance >= 50 ? 'عميل ذهبي' : 'عميل عادي',
                ],
                'financial_summary' => [
                    'borrowed_count'     => $borrowedBooksCount,
                    'purchased_count'    => (int)$purchasedBooksCount,
                    'total_fines_paid'   => number_format($totalExtraFines, 0) . ' ل.س',
                    'total_spend'        => number_format($totalPayments, 0) . ' ل.س',
                ]
            ]
        ]);
    }

    /**
     * إحصائيات عامة للوحة تحكم الأدمن
     */
    public function getTotalPaidOrdersCount(Request $request)
    {
        $totalPaidOrders = \App\Models\Bill::where('status', 'paid')->count();
        $totalRevenue = \App\Models\Bill::where('status', 'paid')->sum('total_price');

        return response()->json([
            'status' => 'success',
            'data' => [
                'total_paid_orders' => $totalPaidOrders,
                'total_revenue'     => number_format($totalRevenue, 0) . ' ل.س',
                'report_date'       => now()->format('Y-m-d H:i')
            ]
        ]);
    }
}
