<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

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

    /**
     * إرسال إشعار جماعي (للأدمن فقط)
     */
    public function sendGlobalNotification(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'body'  => 'required|string',
            'target_screen' => 'nullable|string',
        ]);

        User::with('customer')->where('type', 'customer')->chunk(100, function ($users) use ($data) {
            foreach ($users as $user) {
                if ($user->customer) {
                    try {
                        Notification::send(
                            $user->customer->id,
                            'global_admin_announcement',
                            $data['title'],
                            $data['body'],
                            [
                                'icon' => 'admin_alert',
                                'target_screen' => $data['target_screen'] ?? 'home'
                            ]
                        );
                    } catch (\Exception $e) {
                        Log::warning('Global notification failed for customer ' . $user->customer->id . ': ' . $e->getMessage());
                    }
                }
            }
        });

        return response()->json([
            'success' => true,
            'message' => 'تمت جدولة إرسال الإشعار الجماعي لجميع المستخدمين'
        ], 200);
    }
}
