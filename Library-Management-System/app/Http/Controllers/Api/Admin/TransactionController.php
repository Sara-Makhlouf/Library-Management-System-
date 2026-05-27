<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Notification; 
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $transactions = Transaction::with(['customer', 'book'])
            ->when($request->type, function ($query, $type) {
                return $query->where('type', $type);
            })
            ->latest()
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }

    public function show($id): JsonResponse
    {
        $transaction = Transaction::with(['customer', 'book'])->findOrFail($id);
        return response()->json([
            'status' => 'success',
            'data' => $transaction
        ]);
    }

    public function topBorrowedBooks(Request $request): JsonResponse
    {
        $report = Transaction::whereIn('status', ['received', 'returned'])
            ->select('book_id', DB::raw('count(*) as total_borrows'))
            ->with('book:id,title')
            ->groupBy('book_id')
            ->orderByDesc('total_borrows')
            ->take(5)
            ->get();

        //  إرسال إشعار موحد عند طلب تقرير الكتب الأكثر استعارة
        try {
            Notification::send(
                $request->user()->id,
                'report_top_borrowed',
                'تقرير الكتب الأكثر استعارة 📚📊',
                "تم استخراج تقرير يوضح الكتب الخمسة الأكثر طلباً واستعارة في النظام.",
                [
                    'icon' => 'trending_up',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'data' => $report
        ]);
    }

    public function getTotalBorrowsCount(Request $request)
    {
        $allTransactions = \App\Models\Transaction::count();
        $returnedBorrows = \App\Models\Transaction::where('status', 'returned')->count();
        $activeBorrows = \App\Models\Transaction::where('status', 'received')->count();
        $expiredBorrows = \App\Models\Transaction::where('status', 'expired')->count();

        //  إرسال إشعار موحد عند استعلام الإدارة عن إحصائيات الاستعارة العامة
        try {
            Notification::send(
                $request->user()->id,
                'report_borrows_count',
                'إحصائيات الاستعارات العامة 🔄',
                "تم جلب إجمالي عمليات الاستعارة وحالاتها (النشطة، المسترجعة، والمنتهية).",
                [
                    'icon' => 'analytics_borrows',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'total_count' => $allTransactions,
                'details' => [
                    'returned' => $returnedBorrows,
                    'active' => $activeBorrows,
                    'expired' => $expiredBorrows,
                ],
                'info' => 'تم حساب الإحصائيات بناءً على حالات جدول العمليات'
            ]
        ]);
    }

    public function getWeeklySalesCount(Request $request)
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $weeklySales = \App\Models\Bill::where('status', 'paid')
            ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->count();

        // 🔔 إرسال إشعار موحد عند طلب تقرير المبيعات الأسبوعي
        try {
            Notification::send(
                $request->user()->id,
                'report_weekly_sales',
                'تقرير المبيعات الأسبوعي 📈',
                "تم توليد إحصائية عدد المبيعات المدفوعة خلال هذا الأسبوع الحالي.",
                [
                    'icon' => 'weekly_sales',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'report_type' => 'Weekly Sales',
            'period' => [
                'from' => $startOfWeek->toDateString(),
                'to' => $endOfWeek->toDateString()
            ],
            'total_count' => $weeklySales
        ]);
    }

    public function getWeeklyBorrowsCount(Request $request)
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $weeklyBorrows = \App\Models\Transaction::whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->count();

        //  إرسال إشعار موحد عند طلب تقرير الاستعارات الأسبوعي
        try {
            Notification::send(
                $request->user()->id,
                'report_weekly_borrows',
                'تقرير الاستعارات الأسبوعي 📅',
                "تم توليد تقرير بعدد الكتب المستعارة خلال الأسبوع الحالي بنجاح.",
                [
                    'icon' => 'weekly_borrows',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'report_type' => 'Weekly Borrows',
            'period' => [
                'from' => $startOfWeek->toDateString(),
                'to' => $endOfWeek->toDateString()
            ],
            'total_count' => $weeklyBorrows
        ]);
    }
}