<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\UserReadingProgress;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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
        $customer = $user->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'بيانات العميل غير مكتملة'], 403);
        }

        $book = Book::findOrFail($request->book_id);

        $totalPages = $book->total_pages  ?? 0;

        $page = ($request->current_page > $totalPages && $totalPages > 0) ? $totalPages : $request->current_page;

        $progress = UserReadingProgress::updateOrCreate(
            ['customer_id' => $customer->id, 'book_id' => $request->book_id],
            ['last_page_read' => $page]
        );
        if ($totalPages > 0 && $progress->last_page_read == $totalPages) {
            Notification::send(
                $customer->id,
                'book_completed',
                'أكملت قراءة الكتاب! 🎉',
                "مبروك! أنهيت قراءة كتاب ({$book->title}) بالكامل.",
                ['target_screen' => 'my_library', 'book_id' => $book->id]
            );
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث تقدم القراءة بنجاح',
            'data' => [
                'current_page' => $progress->last_page_read,
                'total_pages'  => $totalPages,
                'is_completed' => ($totalPages > 0) ? ($progress->last_page_read == $totalPages) : false,
            ]
        ]);
    }
    /**
     * جلب قائمة الكتب التي يقرأها المستخدم حالياً (التي لم تنتهِ)
     */
    public function currentReading(Request $request)
    {
        $user = Auth::user();
        $customer = $user->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'بيانات العميل غير موجودة'], 403);
        }

        $readingList = UserReadingProgress::where('customer_id', $customer->id)
            ->with(['book' => function ($q) {
                $q->select('id', 'title', 'cover', 'total_pages');
            }])
            ->whereColumn('last_page_read', '<', DB::raw('(select total_pages from books where books.id = user_reading_progress.book_id)'))
            ->orderBy('updated_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $readingList
        ]);
    }
}
