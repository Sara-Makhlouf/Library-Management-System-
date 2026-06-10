<?php

namespace App\Http\Controllers\Api\Admin;

use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Models\WaitingList;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class WaitingListController extends Controller
{
    use ApiResponse, NotifiesUsers;

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

        return $this->successResponse($list);
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        $entry = WaitingList::with(['book', 'customer'])->find($id);

        if (!$entry) {
            return $this->errorResponse('عذراً، هذا السجل غير موجود في قائمة الانتظار أو تم حذفه بالفعل.', 404);
        }

        $bookTitle = $entry->book->title ?? 'كتاب غير معروف';
        $customerName = $entry->customer->user->name ?? ($entry->customer->name ?? 'زبون');

        $entry->delete();

        $this->notifySafe(
            $request->user()->id,
            'waiting_list_removed',
            'تحديث قائمة الانتظار ⏳',
            "تمت إزالة العميل ({$customerName}) من قائمة انتظار كتاب ({$bookTitle}).",
            ['icon' => 'waiting_remove', 'target_screen' => 'waiting_list_dashboard']
        );

        return $this->successResponse(message: 'تمت إزالة الطلب من قائمة الانتظار بنجاح');
    }

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

        $this->notifySafe(
            $request->user()->id,
            'report_top_waiting',
            'تقرير قائمة الانتظار 📊',
            "تم استخراج تقرير يوضح أكثر الكتب طلباً. الكتاب الأكثر انتظاراً هو: " . ($report->first()->book->title ?? 'غير محدد'),
            ['icon' => 'analytics_waiting', 'target_screen' => 'reports_dashboard']
        );

        return $this->successResponse($report);
    }
}
