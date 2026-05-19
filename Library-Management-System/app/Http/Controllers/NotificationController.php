<?php

namespace App\Http\Controllers;

use App\Models\Notification;
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
}
