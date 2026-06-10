<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\BookRequest;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use App\Traits\ResolvesCustomer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\JsonResponse;

class BookRequestController extends Controller
{
    use ApiResponse, NotifiesUsers, ResolvesCustomer;

    public function index(): JsonResponse
    {
        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $requests = BookRequest::where('customer_id', $customer->id)
            ->latest()
            ->get();

        return $this->successResponse($requests);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'book_title'  => 'required|string|max:255',
            'author_name' => 'nullable|string|max:255',
            'notes'       => 'nullable|string',
        ]);

        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $bookRequest = BookRequest::create([
            'customer_id' => $customer->id,
            'book_title'  => $request->book_title,
            'author_name' => $request->author_name,
            'notes'       => $request->notes,
            'status'      => 'pending',
        ]);

        return $this->successResponse($bookRequest, 'تم استلام طلبك بنجاح، سنحاول توفير الكتاب قريباً');
    }

    public function show($id): JsonResponse
    {
        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $bookRequest = BookRequest::find($id);

        if (!$bookRequest) {
            return $this->errorResponse('عذراً، طلب الكتاب هذا غير موجود في النظام أو تم حذفه.', 404);
        }

        if ($bookRequest->customer_id !== $customer->id) {
            return $this->errorResponse('غير مصرح لك باستعراض تفاصيل هذا الطلب.', 403);
        }

        return $this->successResponse($bookRequest);
    }

    public function destroy($id): JsonResponse
    {
        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $bookRequest = BookRequest::find($id);
        if (!$bookRequest) {
            return $this->errorResponse('عذراً، طلب الكتاب هذا غير موجود أو تم حذفه مسبقاً.', 404);
        }

        if ($bookRequest->customer_id !== $customer->id) {
            return $this->errorResponse('غير مصرح لك بإلغاء هذا الطلب.', 403);
        }

        if ($bookRequest->status !== 'pending') {
            return $this->errorResponse("لا يمكن إلغاء الطلب لأن حالته الحالية هي ({$bookRequest->status}) ولم يعد قيد الانتظار.", 422);
        }

        $bookRequest->delete();

        return $this->successResponse(message: 'تم إلغاء طلب الكتاب بنجاح.');
    }

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

        $this->notifySafe(
            $bookRequest->customer->id,
            'book_request_updated',
            'تحديث على طلب كتابك 📚',
            "تمت معالجة طلبك للكتاب ({$bookRequest->book_title}) وحالته: " .
                ($request->status === 'approved' ? 'مقبول' : 'مرفوض'),
            ['target_screen' => 'my_requests']
        );

        return $this->successResponse($bookRequest, 'تم تحديث حالة طلب الكتاب بنجاح وإشعار الزبون');
    }
}
