<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\UserReadingProgress;
use App\Models\Book;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use App\Traits\ResolvesCustomer;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class ReadingController extends Controller
{
    use ApiResponse, NotifiesUsers, ResolvesCustomer;

    public function updateProgress(Request $request): JsonResponse
    {
        $request->validate([
            'book_id'      => 'required|exists:books,id',
            'current_page' => 'required|integer|min:1',
        ]);

        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $book = Book::findOrFail($request->book_id);

        $totalPages = $book->total_pages ?? 0;

        $page = ($request->current_page > $totalPages && $totalPages > 0) ? $totalPages : $request->current_page;

        $progress = UserReadingProgress::updateOrCreate(
            ['customer_id' => $customer->id, 'book_id' => $request->book_id],
            ['last_page_read' => $page]
        );

        if ($totalPages > 0 && $progress->last_page_read == $totalPages) {
            $this->notifySafe(
                $customer->id,
                'book_completed',
                'أكملت قراءة الكتاب! 🎉',
                "مبروك! أنهيت قراءة كتاب ({$book->title}) بالكامل.",
                ['target_screen' => 'my_library', 'book_id' => $book->id]
            );
        }

        return $this->successResponse([
            'current_page' => $progress->last_page_read,
            'total_pages'  => $totalPages,
            'is_completed' => ($totalPages > 0) ? ($progress->last_page_read == $totalPages) : false,
        ], 'تم تحديث تقدم القراءة بنجاح');
    }

    public function currentReading(Request $request): JsonResponse
    {
        $customer = $this->resolveCustomer();
        if ($customer instanceof JsonResponse) return $customer;

        $readingList = UserReadingProgress::where('customer_id', $customer->id)
            ->with(['book' => function ($q) {
                $q->select('id', 'title', 'cover', 'total_pages');
            }])
            ->whereColumn('last_page_read', '<', DB::raw('(select total_pages from books where books.id = user_reading_progress.book_id)'))
            ->orderBy('updated_at', 'desc')
            ->get();

        return $this->successResponse($readingList);
    }
}
