<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    use ApiResponse, NotifiesUsers;

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

        return $this->successResponse($users);
    }

    public function show($id): JsonResponse
    {
        $user = User::with(['customer' => function ($q) {
            $q->withCount(['bills', 'transactions']);
        }])->findOrFail($id);

        return $this->successResponse($user);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        $user = User::with('customer')->findOrFail($id);
        $customerName = $user->customer->name ?? 'مستخدم غير معروف';

        $user->delete();

        $this->notifySafe(
            $request->user()->id,
            'user_deleted',
            'حذف حساب مستخدم ⚠️',
            "تم حذف حساب المستخدم ({$customerName}) وجميع بياناته بنجاح.",
            ['icon' => 'user_delete', 'target_screen' => 'users_dashboard']
        );

        return $this->successResponse(message: 'تم حذف المستخدم بنجاح');
    }

    public function getFullUserDetails(Request $request, $id)
    {
        $customer = Customer::find($id);

        if (!$customer) {
            return $this->errorResponse('الزبون غير موجود', 404);
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

        $this->notifySafe(
            $request->user()->id,
            'user_report_viewed',
            'استعراض ملف العميل المالي 👤',
            "تم جلب التقرير المالي الشامل للعميل ({$customer->name}).",
            ['icon' => 'user_analytics', 'target_screen' => 'user_details', 'customer_id' => $customer->id]
        );

        return $this->successResponse([
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
        ]);
    }

    public function getTotalPaidOrdersCount(Request $request)
    {
        $totalPaidOrders = \App\Models\Bill::where('status', 'paid')->count();
        $totalRevenue = \App\Models\Bill::where('status', 'paid')->sum('total_price');

        return $this->successResponse([
            'total_paid_orders' => $totalPaidOrders,
            'total_revenue'     => number_format($totalRevenue, 0) . ' ل.س',
            'report_date'       => now()->format('Y-m-d H:i')
        ]);
    }
}
