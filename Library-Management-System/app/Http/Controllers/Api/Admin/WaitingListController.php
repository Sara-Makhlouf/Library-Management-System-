<?php

namespace App\Http\Controllers\Api\Admin;

use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Models\WaitingList;
use App\Models\Notification; 
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class WaitingListController extends Controller
{
    /**
     * عرض قائمة الانتظار كاملة مع أسماء الزبائن وعناوين الكتب
     */
    public function index(): JsonResponse
    {
        $list = WaitingList::with(['customer', 'book'])
            ->latest()
            ->get();

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
        $entry = WaitingList::findOrFail($id);
        $bookTitle = $entry->book->title ?? 'كتاب غير معروف';
        
        $entry->delete();

        // 🔔 إرسال إشعار موحد عند إزالة طلب من قائمة الانتظار
        try {
            Notification::send(
                $request->user()->id, // معرف الآدمن الحالي من الـ Token
                'waiting_list_removed',
                'تحديث قائمة الانتظار ⏳',
                "تمت إزالة طلب من قائمة الانتظار المخصصة لكتاب ({$bookTitle}) بنجاح.",
                [
                    'icon' => 'waiting_remove',
                    'target_screen' => 'waiting_list_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز أي خطأ طارئ لضمان استقرار العملية
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إزالة الطلب من قائمة الانتظار'
        ]);
    }

    /**
     * تقرير الكتب الأكثر طلباً في قائمة الانتظار
     */
    public function topWaitingBooks(Request $request): JsonResponse
    {
        $report = WaitingList::select('book_id', DB::raw('count(*) as waiting_count'))
            ->with('book:id,title')
            ->groupBy('book_id')
            ->orderByDesc('waiting_count')
            ->take(5)
            ->get();

        //  إرسال إشعار موحد عند طلب تقرير كتب قائمة الانتظار الأعلى طلباً
        try {
            Notification::send(
                $request->user()->id,
                'report_top_waiting',
                'تقرير قائمة الانتظار 📊',
                "تم استخراج تقرير يوضح الكتب الخمسة الأكثر طلباً وانتظاراً من قبل القراء.",
                [
                    'icon' => 'analytics_waiting',
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
}