<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $customerId = $request->user()->id;
        $notifications = Notification::forCustomer($customerId)
            ->orderBy('created_at', 'desc')->get();
        return response()->json([
            'success' => true,
            'data' => $notifications
        ]);
    }
    public function unreadCount(Request $request): JsonResponse
    {
        $customerId = $request->user()->id;
        $count = Notification::forCoustomer($customerId)
            ->unread()
            ->count();
        return response()->json([
            'success' => true,
            'data' => $count
        ]);
    }

    public function markAsRead(int $id, Request $request): JsonResponse
    {
        $customerId = $request->user()->id;
        $notification = Notification::where('id', $id)
            ->where('customer_id', $customerId)
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'message' => 'تم تعيين الإشعار كمقروء بنجاح'
        ]);
    }
    public function sendGlobalNotification(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'body'  => 'required|string',
            'target_screen' => 'nullable|string',
        ]);

        $users = User::all();
        foreach ($users as $user) {
            Notification::send(
                $user->id,
                'global_admin_announcement',
                $data['title'],
                $data['body'],
                [
                    'icon' => 'admin_alert',
                    'target_screen' => $data['target_screen'] ?? 'home'
                ]
            );
        }
        return response()->json([
            'message' => 'تم إرسال الإشعار الجماعي بنجاح إلى جميع المستخدمين'

        ], 200);
    }
}
