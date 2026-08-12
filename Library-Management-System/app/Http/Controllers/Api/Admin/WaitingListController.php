<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Notification;
use App\Models\WaitingList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WaitingListController extends Controller
{

    /**
     * انضمام الزبون لقائمة انتظار كتاب غير متوفر
     */
    public function join(Request $request, $bookId): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['message' => 'سجل الزبون غير موجود'], 404);
        }

        $book = Book::findOrFail($bookId);

        if ($book->stock > 0) {
            return response()->json(['message' => 'الكتاب متوفر حالياً بالمخزون ويمكنك استعارته مباشرة'], 400);
        }

        $alreadyWaiting = WaitingList::where('book_id', $book->id)
            ->where('customer_id', $customer->id)
            ->exists();

        if ($alreadyWaiting) {
            return response()->json(['message' => 'أنت مضاف بالفعل إلى قائمة الانتظار لهذا الكتاب'], 400);
        }

        $waitingEntry = WaitingList::create([
            'book_id'     => $book->id,
            'customer_id' => $customer->id,
            'created_at'  => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'تمت إضافتك إلى قائمة الانتظار بنجاح 📚',
            'data'    => $waitingEntry
        ], 201);
    }

    /**
     * إلغاء انضمام الزبون لقائمة الانتظار بنفسه
     */
    public function leave(Request $request, $bookId): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['message' => 'سجل الزبون غير موجود'], 404);
        }

        $deleted = WaitingList::where('book_id', $bookId)
            ->where('customer_id', $customer->id)
            ->delete();

        if (!$deleted) {
            return response()->json(['message' => 'أنت غير موجود في قائمة الانتظار لهذا الكتاب'], 404);
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم إلغاء الانضمام لقائمة الانتظار بنجاح'
        ]);
    }

    /**
     * عرض قائمة الانتظار الخاصة بالزبون المسجل حالياً
     */
    public function myWaitingList(Request $request): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json(['message' => 'سجل الزبون غير موجود'], 404);
        }

        $list = WaitingList::where('customer_id', $customer->id)
            ->with('book:id,title,cover,stock')
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $list
        ]);
    }


    /**
     * عرض كل قائمة الانتظار للأدمن
     */
    public function index(Request $request): JsonResponse
    {
        $list = WaitingList::with(['customer.user', 'book' => function ($q) {
            $q->withTrashed();
        }])
            ->when($request->book_id, function ($query, $bookId) {
                return $query->where('book_id', $bookId);
            })
            ->latest()
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data'   => $list
        ]);
    }

    /**
     * إزالة زبون من قائمة الانتظار من قبل الأدمن (مع إشعاره)
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $entry = WaitingList::with(['book', 'customer.user'])->find($id);

        if (!$entry) {
            return response()->json([
                'status'  => 'error',
                'message' => 'عذراً، هذا السجل غير موجود في قائمة الانتظار أو تم حذفه بالفعل.'
            ], 404);
        }

        $bookTitle = $entry->book->title ?? 'كتاب غير معروف';
        $customerId = $entry->customer_id;

        $entry->delete();

        if ($customerId) {
            try {
                Notification::send(
                    $customerId,
                    'waiting_list_removed',
                    'تحديث قائمة الانتظار ⏳',
                    "تمت إزالتك من قائمة انتظار كتاب ({$bookTitle}).",
                    [
                        'icon'          => 'waiting_remove',
                        'target_screen' => 'waiting_list'
                    ]
                );
            } catch (\Exception $e) {
                // يتخطى الخطأ لضمان استمرار الحذف
            }
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تمت إزالة الطلب من قائمة الانتظار بنجاح'
        ]);
    }

    /**
     * تقرير الأدمن لأكثر الكتب طلباً في قائمة الانتظار
     */
    public function topWaitingBooks(): JsonResponse
    {
        $report = Book::withTrashed()
            ->withCount('waiters as waiting_count')
            ->has('waiters')
            ->orderByDesc('waiting_count')
            ->take(5)
            ->get(['id', 'title', 'cover']);

        return response()->json([
            'status' => 'success',
            'data'   => $report
        ]);
    }
}
