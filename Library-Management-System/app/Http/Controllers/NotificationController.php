<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * عرض قائمة إشعارات الزبون الحالي
     */
    public function index(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;
        $notifications = Notification::where('customer_id', $customer->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $notifications
        ]);
    }

    /**
     * جلب عدد الإشعارات غير المقروءة فقط
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;

        $count = Notification::where('customer_id', $customer->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => $count
        ]);
    }

    /**
     * تعيين إشعار معين كمقروء
     */
    public function markAsRead(int $id, Request $request): JsonResponse
    {
        $customer = $request->user()->customer;

        $notification = Notification::where('id', $id)
            ->where('customer_id', $customer->id)
            ->firstOrFail();

        $notification->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'تم تعيين الإشعار كمقروء بنجاح'
        ]);
    }
    public function markAllAsRead(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;
        $notification = Notification::where('customer_id', $customer->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);
        return response()->json([
            'success' => true,
            'message' => 'تم تعيين جميع الأشعارات كمقروء بنجاح'
        ]);
    }
    /**
     * إرسال إشعار جماعي (للأدمن فقط)
     */
    public function sendGlobalNotification(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title'         => 'required|string|max:255',
            'body'          => 'required|string',
            'target_screen' => 'nullable|string',
        ]);

        $customerIds = Customer::pluck('id');

        if ($customerIds->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد زبائن لإرسال الإشعار إليهم'
            ], 400);
        }

        $now = now();
        $notificationsToInsert = [];

        foreach ($customerIds as $customerId) {
            $notificationsToInsert[] = [
                'customer_id'   => $customerId,
                'type'          => 'global_admin_announcement',
                'title'         => $data['title'],
                'body'          => $data['body'],
                'data'          => json_encode([
                    'icon'          => 'admin_alert',
                    'target_screen' => $data['target_screen'] ?? 'home'
                ]),
                'is_read'       => false,
                'created_at'    => $now,
                'updated_at'    => $now,
            ];
        }

        foreach (array_chunk($notificationsToInsert, 500) as $chunk) {
            Notification::insert($chunk);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال الإشعار الجماعي لجميع المستخدمين بنجاح'
        ], 200);
    }
}
