<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Models\Notification; // استدعاء الموديل الموحد هنا ✅
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    // عرض قائمة العملاء مع البحث
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

    // عرض تفاصيل عميل واحد
    public function show($id): JsonResponse
    {
        $user = User::with('customer')->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $user
        ]);
    }

    // حذف حساب عميل
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $customerName = $user->customer->name ?? 'غير معروف';
        
        $user->delete();

        // 🔔 إرسال إشعار موحد عند حذف الحساب
        try {
            Notification::send(
                $request->user()->id,
                'user_deleted',
                'حذف حساب مستخدم ⚠️',
                "تم حذف حساب المستخدم ({$customerName}) وبياناته الشخصية نهائياً من النظام.",
                [
                    'icon' => 'user_delete',
                    'target_screen' => 'users_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ لضمان استقرار العملية
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف المستخدم وبياناته الشخصية بنجاح'
        ]);
    }

    // جلب التفاصيل المالية والنشاطات الشاملة للمستخدم
    public function getFullUserDetails(Request $request, $id)
    {
        $customer = Customer::withCount('bills')->find($id);

        if (!$customer) {
            return response()->json(['message' => 'الزبون غير موجود'], 404);
        }
        
        $borrowedBooksCount = $customer->transactions()
            ->whereNotNull('due_date')
            ->count();

        $purchasedBooksCount = $customer->purchasedItems()->sum('quantity');
        $totalMortgageAmount = $customer->transactions()->sum('mortgage');
        $totalExtraFines = $customer->transactions()->sum('extra_price');

        $totalPayments = $customer->bills()
            ->where('status', 'paid')
            ->sum('total_price');

        // 🔔 إرسال إشعار موحد عند طلب تقرير نشاطات مستخدم معين
        try {
            Notification::send(
                $request->user()->id,
                'user_report_viewed',
                'استعراض ملف العميل المالي 👤',
                "تم استخراج تقرير النشاط والملف المالي الشامل للعميل ({$customer->name}).",
                [
                    'icon' => 'user_analytics',
                    'target_screen' => 'user_details',
                    'customer_id' => $customer->id
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'profile' => [
                    'name' => $customer->name,
                    'points' => $customer->points_balance,
                    'app_status' => $customer->points_balance >= 25 ? 'عضو نشط' : 'عضو عادي',
                ],
                'activity_report' => [
                    'borrowed_books' => $borrowedBooksCount,
                    'purchased_books' => (int)$purchasedBooksCount,
                    'total_mortgage_paid' => number_format($totalMortgageAmount, 2),
                    'total_fines' => number_format($totalExtraFines, 2),
                    'total_paid_on_app' => number_format($totalPayments, 2),
                ]
            ]
        ]);
    }

    // جلب إحصائيات الطلبات المدفوعة والأرباح الكلية
    public function getTotalPaidOrdersCount(Request $request)
    {
        $totalPaidOrders = \App\Models\Bill::where('status', 'paid')->count();
        $totalRevenue = \App\Models\Bill::where('status', 'paid')->sum('total_price');

        // 🔔 إرسال إشعار موحد عند طلب تقرير الطلبات الإجمالي في النظام
        try {
            Notification::send(
                $request->user()->id,
                'orders_report_viewed',
                'تقرير الفواتير الإجمالي 🧾',
                "تم جلب عدد الطلبات المدفوعة وإجمالي الأرباح الكلية المحققة في التطبيق.",
                [
                    'icon' => 'orders_analytics',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'total_paid_orders_count' => $totalPaidOrders,
                'total_revenue' => number_format($totalRevenue, 2) . ' SYP',
                'last_updated' => now()->toDateTimeString()
            ]
        ]);
    }
}