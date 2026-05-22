<?php

namespace App\Http\Controllers\Api\Admin;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use App\Models\WaitingList;
use Illuminate\Http\JsonResponse;

class WaitingListController extends Controller
{
    // عرض قائمة الانتظار كاملة مع أسماء الزبائن وعناوين الكتب

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

    // حذف طلب من قائمة الانتظار
    public function destroy($id): JsonResponse
    {
        $entry = WaitingList::findOrFail($id);
        $entry->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إزالة الطلب من قائمة الانتظار'
        ]);
    }

  public function topWaitingBooks(): JsonResponse
    {
        $report = WaitingList::select('book_id', DB::raw('count(*) as waiting_count'))
            ->with('book:id,title')
            ->groupBy('book_id')
            ->orderByDesc('waiting_count')
            ->take(5)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $report
        ]);
    }
}

