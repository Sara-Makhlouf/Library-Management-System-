<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\User;
use App\Models\Category;
use App\Models\Customer;
use App\Models\Bill;
use App\Models\Transaction;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $activeThreshold = 25;

        $baseRevenue = Bill::where('status', 'paid')->sum('total_price');
        $finesRevenue = Transaction::where('type', 'borrow')->sum('extra_price');

        $stats = [
            'total_books'          => Book::count(),
            'total_customers'      => Customer::count(),
            'total_categories'     => Category::count(),
            'active_members'       => Customer::where('points_balance', '>=', $activeThreshold)->count(),
            'total_revenue'        => (float) ($baseRevenue + $finesRevenue),
            'current_borrowed'     => Transaction::where('type', 'borrow')->where('status', 'received')->count(),
        ];

        $booksPerCategory = Category::withCount(['books' => function ($q) {
            $q->whereNull('deleted_at');
        }])->get(['id', 'name'])->map(fn($category) => [
            'name'  => $category->name,
            'count' => $category->books_count
        ]);

        $recentUsers = User::where('type', 'customer')
            ->has('customer')
            ->with('customer')
            ->latest()
            ->take(5)
            ->get(['id', 'email', 'created_at'])
            ->map(fn($user) => [
                'id'        => $user->id,
                'name'      => $user->customer->name ?? 'مستخدم جديد',
                'email'     => $user->email,
                'joined_at' => $user->created_at->diffForHumans()
            ]);

        $latestBooks = Book::with('authors:name')
            ->latest()
            ->take(5)
            ->get(['id', 'title', 'price', 'sale_price'])
            ->map(fn($book) => [
                'id'           => $book->id,
                'title'        => $book->title,
                'borrow_price' => $book->price,
                'sale_price'   => $book->sale_price,
                'average_rate' => $book->average_rate,
                'authors'      => $book->authors->pluck('name')
            ]);

        // 🔔 إرسال إشعار الدخول للوحة التحكم بشكل آمن
        $this->sendDashboardNotification($request->user()->id, $stats);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'counts'             => $stats,
                'books_per_category' => $booksPerCategory,
                'recent_users'       => $recentUsers,
                'latest_books'       => $latestBooks,
            ]
        ]);
    }


    private function sendDashboardNotification(int $userId, array $stats): void
    {
        try {
            Notification::send(
                $userId,
                'dashboard_viewed',
                'استعراض لوحة التحكم 📊',
                "تم استعراض إحصائيات النظام. المجموع الحالي للكتب: ({$stats['total_books']}) والإيرادات الإجمالية: (" . number_format($stats['total_revenue'], 2) . " ل.س).",
                ['icon' => 'dashboard_overview', 'target_screen' => 'admin_dashboard']
            );
        } catch (\Exception $e) {
            Log::warning('Dashboard notification failed: ' . $e->getMessage());
        }
    }
}
