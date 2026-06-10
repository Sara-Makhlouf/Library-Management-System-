<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\BookRequest;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\JsonResponse;

class BookRequestController extends Controller
{
    /**
     * 1. عرض جميع طلبات الكتب الخاصة بالزبون الحالي
     */
    public function index(): JsonResponse
    {
        $customer = Auth::user()->customer;

        $requests = BookRequest::where('customer_id', $customer->id)
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $requests
        ]);
    }

    /**
     * 2. إرسال طلب كتاب جديد من الزبون
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'book_title'  => 'required|string|max:255',
            'author_name' => 'nullable|string|max:255',
            'notes'       => 'nullable|string',
        ]);

        $customer = Auth::user()->customer;

        $bookRequest = BookRequest::create([
            'customer_id' => $customer->id,
            'book_title'  => $request->book_title,
            'author_name' => $request->author_name,
            'notes'       => $request->notes,
            'status'      => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم استلام طلبك بنجاح، سنحاول توفير الكتاب قريباً',
            'data' => $bookRequest
        ]);
    }

    /**
     * 3. عرض تفاصيل طلب معين للزبون
     */
    public function show($id): JsonResponse
    {
        $customer = Auth::user()->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط بملف زبون.'
            ], 403);
        }

        $bookRequest = BookRequest::find($id);

        if (!$bookRequest) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، طلب الكتاب هذا غير موجود في النظام أو تم حذفه.'
            ], 404);
        }

        if ($bookRequest->customer_id !== $customer->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'غير مصرح لك باستعراض تفاصيل هذا الطلب.'
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data' => $bookRequest
        ]);
    }

    /**
     * 4. إلغاء طلب كتاب من قبل الزبون (فقط إذا كان معلقاً pending)
     */
    public function destroy($id): JsonResponse
    {
        $customer = Auth::user()->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط بملف زبون.'
            ], 403);
        }

        $bookRequest = BookRequest::find($id);
        if (!$bookRequest) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، طلب الكتاب هذا غير موجود أو تم حذفه مسبقاً.'
            ], 404);
        }

        if ($bookRequest->customer_id !== $customer->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'غير مصرح لك بإلغاء هذا الطلب.'
            ], 403);
        }

        if ($bookRequest->status !== 'pending') {
            return response()->json([
                'status' => 'error',
                'message' => "لا يمكن إلغاء الطلب لأن حالته الحالية هي ({$bookRequest->status}) ولم يعد قيد الانتظار."
            ], 422);
        }

        $bookRequest->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم إلغاء طلب الكتاب بنجاح.'
        ]);
    }

    /**
     * 5. دالة الأدمن لمعالجة الطلب (قبول أو رفض)
     */
    public function updateStatus(Request $request, $id): JsonResponse
    {
        $request->validate([
            'status'     => 'required|in:approved,rejected,pending',
            'admin_note' => 'nullable|string'
        ]);

        $bookRequest = BookRequest::findOrFail($id);
        $bookRequest->update([
            'status'     => $request->status,
            'admin_note' => $request->admin_note
        ]);
        try {
            // إرسال إشعار للزبون يبلغه بتحديث حالة طلبه
            Notification::send(
                $bookRequest->customer->id,
                'book_request_updated',
                'تحديث على طلب كتابك 📚',
                "تمت معالجة طلبك للكتاب ({$bookRequest->book_title}) وحالته: " .
                    ($request->status === 'approved' ? 'مقبول ✅' : 'مرفوض ❌'),
                ['target_screen' => 'my_requests']
            );
        } catch (\Exception $e) {
            Log::warning('Book request notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث حالة طلب الكتاب بنجاح وإشعار الزبون',
            'data' => $bookRequest
        ]);
    }
}
