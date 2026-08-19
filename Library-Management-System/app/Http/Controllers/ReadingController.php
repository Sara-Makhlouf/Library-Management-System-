<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\UserReadingProgress;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Notification;

class ReadingController extends Controller
{
    /**
     * تحديث تقدم القراءة لكتاب معين
     */
    public function updateProgress(Request $request)
    {
        $request->validate([
            'book_id'      => 'required|exists:books,id',
            'current_page' => 'required|integer|min:1',
        ]);

        $user = Auth::user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'بيانات العميل غير مكتملة'], 403);
        }

        $book = Book::findOrFail($request->book_id);
        $totalPages = $book->total_pages ?? 0;

        $page = ($totalPages > 0 && $request->current_page > $totalPages) ? $totalPages : $request->current_page;

        $existingProgress = UserReadingProgress::where('customer_id', $customer->id)
            ->where('book_id', $request->book_id)
            ->first();

        $previousPage = $existingProgress?->last_page_read ?? 0;

        $progress = UserReadingProgress::updateOrCreate(
            ['customer_id' => $customer->id, 'book_id' => $request->book_id],
            ['last_page_read' => $page]
        );

        $isCompleted = ($totalPages > 0) && ($progress->last_page_read == $totalPages);

        // إرسال الإشعار فقط إذا أنهى الكتاب الآن ولم يكن مكملاً له سابقاً
        if ($isCompleted && $previousPage < $totalPages) {
            Notification::send(
                $customer->id,
                'book_completed',
                'أكملت قراءة الكتاب! 🎉',
                "مبروك! أنهيت قراءة كتاب ({$book->title}) بالكامل.",
                ['target_screen' => 'my_library', 'book_id' => $book->id]
            );
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم تحديث تقدم القراءة بنجاح',
            'data'    => [
                'current_page' => $progress->last_page_read,
                'total_pages'  => $totalPages,
                'is_completed' => $isCompleted,
            ]
        ], 200);
    }

    /**
     * جلب قائمة الكتب التي يقرأها المستخدم حالياً (التي لم تنتهِ)
     */
    public function currentReading(Request $request)
    {
        $user = Auth::user();
        $customer = $user?->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'بيانات العميل غير موجودة'], 403);
        }

        $readingList = UserReadingProgress::where('customer_id', $customer->id)
            ->whereHas('book', function ($query) {
                $query->whereColumn('user_reading_progress.last_page_read', '<', 'books.total_pages');
            })
            ->with(['book:id,title,cover,total_pages'])
            ->orderBy('updated_at', 'desc')
            ->get();

        $readingList->transform(function ($item) {
            if ($item->book) {
                $item->book->cover_url = $item->book->cover
                    ? asset('storage/' . $item->book->cover)
                    : asset('storage/covers/default.png');
            }
            return $item;
        });

        return response()->json([
            'status' => 'success',
            'data'   => $readingList
        ], 200);
    }
}
