<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Notification;
use App\Models\Bill;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class TransactionController extends Controller
{
    /**
     * 1. عرض كل العمليات مع فلترة حسب الحالة (مع جلب بيانات المستخدم والعميل والكتاب المتوفى منطقياً)
     */
    public function index(Request $request): JsonResponse
    {
        $transactions = Transaction::with([
            'user.customer',
            'book' => function ($q) {
                $q->withTrashed();
            }
        ])
            ->when($request->status, function ($query, $status) {
                return $query->where('status', $status);
            })
            ->latest()
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }

    /**
     * 2. تقرير: الكتب الخمسة الأكثر استعارة (تاريخياً)
     */
    public function topBorrowedBooks(Request $request): JsonResponse
    {
        $report = Transaction::whereIn('status', ['received', 'returned', 'expired', 'damaged'])
            ->select('book_id', DB::raw('count(*) as total_borrows'))
            ->with(['book' => function ($q) {
                $q->withTrashed()->select('id', 'title');
            }])
            ->groupBy('book_id')
            ->orderByDesc('total_borrows')
            ->take(5)
            ->get();

        try {
            if ($request->user()) {
                Notification::send(
                    $request->user()->id,
                    'report_top_borrowed',
                    'تقرير الكتب الأكثر استعارة 📚📊',
                    "تم استخراج تقرير يوضح الكتب الخمسة الأكثر طلباً في النظام.",
                    ['icon' => 'trending_up', 'target_screen' => 'reports_dashboard']
                );
            }
        } catch (\Exception $e) {
            Log::warning('Top borrowed books notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'data' => $report
        ]);
    }

    /**
     * 3. إحصائيات عامة مقسمة ومفلترة للحالات الثلاث الأساسية
     */
    public function getTotalBorrowsCount(Request $request): JsonResponse
    {
        $allTransactions = Transaction::with(['book', 'user'])->latest()->get();

        $formatList = function ($transactions) {
            return $transactions->map(function ($transaction) {
                return [
                    'transaction_id' => $transaction->id,
                    'type'           => $transaction->type,
                    'status'         => $transaction->status,
                    'price'          => $transaction->price,
                    'delivered_at'   => $transaction->delivered_at,
                    'due_date'       => $transaction->due_date,
                    'book_id'        => $transaction->book_id,
                    'book_title'     => $transaction->book?->title,
                    'book_cover'     => $transaction->book?->cover,
                    'user_id'        => $transaction->user_id,
                    'user_name'      => $transaction->user?->name,
                    'user_email'     => $transaction->user?->email,
                ];
            })->values();
        };

        $grouped = $allTransactions->groupBy('status');

        $stats = [
            'returned' => [
                'count' => $grouped->get('returned', collect())->count(),
                'list'  => $formatList($grouped->get('returned', collect()))
            ],
            'active' => [
                'count' => $grouped->get('received', collect())->count(),
                'list'  => $formatList($grouped->get('received', collect()))
            ],
            'expired' => [
                'count' => $grouped->get('expired', collect())->count(),
                'list'  => $formatList($grouped->get('expired', collect()))
            ],
        ];

        // 5. إرسال الإشعار
        try {
            if ($request->user()) {
                Notification::send(
                    $request->user()->id,
                    'report_borrows_count',
                    'إحصائيات الاستعارات النظيفة 🔄',
                    "تم جلب البيانات وتنسيقها بنجاح.",
                    ['icon' => 'analytics_borrows', 'target_screen' => 'reports_dashboard']
                );
            }
        } catch (\Exception $e) {
            Log::warning('Borrows count notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'data'   => $stats
        ]);
    }

    /**
     * 4. تقرير المبيعات الأسبوعي (عدد الفواتير المدفوعة)
     */
    public function getWeeklySalesCount(Request $request): JsonResponse
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $weeklySales = Bill::where('status', 'paid')
            ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->count();

        $revenue = Bill::where('status', 'paid')
            ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->sum('total_price');

        return response()->json([
            'status' => 'success',
            'period' => [
                'from' => $startOfWeek->toDateString(),
                'to'   => $endOfWeek->toDateString()
            ],
            'total_orders' => $weeklySales,
            'total_revenue' => number_format($revenue) . ' SYP'
        ]);
    }

    /**
     * 5. تقرير الاستعارات الأسبوعي
     */
    public function getWeeklyBorrowsCount(Request $request): JsonResponse
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $weeklyBorrows = Transaction::where('type', 'borrow')
            ->whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->count();

        return response()->json([
            'status' => 'success',
            'period' => [
                'from' => $startOfWeek->toDateString(),
                'to'   => $endOfWeek->toDateString()
            ],
            'total_borrows' => $weeklyBorrows
        ]);
    }
}
