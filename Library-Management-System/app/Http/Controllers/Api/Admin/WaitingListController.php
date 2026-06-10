<?php

namespace App\Http\Controllers\Api\Admin;

use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Models\WaitingList;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class WaitingListController extends Controller
{
    /**
     * عرض قائمة الانتظار مع إمكانية البحث برقم الكتاب
     */
    public function index(Request $request): JsonResponse
    {
        $list = WaitingList::with(['customer', 'book' => function ($q) {
            $q->withTrashed();
        }])
            ->when($request->book_id, function ($query, $bookId) {
                return $query->where('book_id', $bookId);
            })
            ->latest()
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $list
        ]);
    }

    /**
     * حذف طلب من قائمة الانتظار
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $entry = WaitingList::with(['book', 'customer'])->find($id);

        if (!$entry) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا السجل غير موجود في قائمة الانتظار أو تم حذفه بالفعل.'
            ], 404);
        }

        $bookTitle = $entry->book->title ?? 'كتاب غير معروف';
        $customerName = $entry->customer->user->name ?? ($entry->customer->name ?? 'زبون');

        $entry->delete();

        try {
            Notification::send(
                $request->user()->id,
                'waiting_list_removed',
                'تحديث قائمة الانتظار ⏳',
                "تمت إزالة العميل ({$customerName}) من قائمة انتظار كتاب ({$bookTitle}).",
                [
                    'icon' => 'waiting_remove',
                    'target_screen' => 'waiting_list_dashboard'
                ]
            );
        } catch (\Exception $e) {
            Log::warning('Waiting list removal notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إزالة الطلب من قائمة الانتظار بنجاح'
        ]);
    }

    /**
     * تقرير الكتب الأكثر طلباً
     */
    public function topWaitingBooks(Request $request): JsonResponse
    {
        $report = WaitingList::select('book_id', DB::raw('count(*) as waiting_count'))
            ->with(['book' => function ($q) {
                $q->withTrashed()->select('id', 'title');
            }])
            ->groupBy('book_id')
            ->orderByDesc('waiting_count')
            ->take(5)
            ->get();

        try {
            Notification::send(
                $request->user()->id,
                'report_top_waiting',
                'تقرير قائمة الانتظار 📊',
                "تم استخراج تقرير يوضح أكثر الكتب طلباً. الكتاب الأكثر انتظاراً هو: " . ($report->first()->book->title ?? 'غير محدد'),
                [
                    'icon' => 'analytics_waiting',
                    'target_screen' => 'reports_dashboard'
                ]
            );
        } catch (\Exception $e) {
            Log::warning('Top waiting books notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'data' => $report
        ]);
    }
}
