<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    use ApiResponse, NotifiesUsers;

    public function index(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;
        $notifications = Notification::where('customer_id', $customer->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return $this->successResponse($notifications);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;

        $count = Notification::where('customer_id', $customer->id)
            ->where('is_read', false)
            ->count();

        return $this->successResponse($count);
    }

    public function markAsRead(int $id, Request $request): JsonResponse
    {
        $customer = $request->user()->customer;

        $notification = Notification::where('id', $id)
            ->where('customer_id', $customer->id)
            ->firstOrFail();

        $notification->update(['is_read' => true]);

        return $this->successResponse(message: 'تم تعيين الإشعار كمقروء بنجاح');
    }

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
                    $this->notifySafe(
                        $user->customer->id,
                        'global_admin_announcement',
                        $data['title'],
                        $data['body'],
                        [
                            'icon' => 'admin_alert',
                            'target_screen' => $data['target_screen'] ?? 'home'
                        ]
                    );
                }
            }
        });

        return $this->successResponse(message: 'تمت جدولة إرسال الإشعار الجماعي لجميع المستخدمين');
    }
}
