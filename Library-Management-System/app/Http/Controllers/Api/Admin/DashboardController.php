<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\User;
use App\Models\Category;
use App\Models\Customer;
use App\Models\Notification;
use Illuminate\Http\Request; 
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $activeThreshold = 25;

        // 🔔 إضافة دالة الإشعار الموحدة فقط عند استعراض لوحة التحكم
        try {
            Notification::send(
                $request->user()->id, // معرف الآدمن الحالي من الـ Token بأمان
                'dashboard_viewed',
                'استعراض لوحة التحكم 📊',
                "تم دخول لوحة تحكم الإدارة واستعراض التقارير وإحصائيات النظام العامة بنجاح.",
                [
                    'icon' => 'dashboard_overview',
                    'target_screen' => 'admin_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز أي خطأ طارئ لضمان استقرار العملية
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'counts' => [
                    'total_books' => Book::count(),
                    'total_users' => User::count(),
                    'total_categories' => Category::count(),
                    'active_members' => Customer::where('points_balance', '>=', $activeThreshold)->count(),
                ],

                'books_per_category' => Category::withCount('books')->get()->map(function($category) {
                    return [
                        'name' => $category->name,
                        'count' => $category->books_count
                    ];
                }),

                'recent_users' => User::with('customer:user_id,name')
                    ->where('type', 'customer')
                    ->latest()
                    ->take(8)
                    ->get(['id', 'email', 'created_at'])
                    ->map(function($user) {
                        return [
                            'id' => $user->id,
                            'name' => $user->customer->name ?? 'N/A',
                            'email' => $user->email,
                            'created_at' => $user->created_at
                        ];
                    }),

                'latest_books' => Book::with('authors:name')
                    ->latest()
                    ->take(4)
                    ->get(['id', 'title'])
                    ->map(function($book) {
                        return [
                            'id' => $book->id,
                            'title' => $book->title,
                            'authors' => $book->authors->pluck('name')
                        ];
                    }),
            ]
        ]);
    }
}