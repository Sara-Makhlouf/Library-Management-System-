<?php

namespace App\Http\Controllers;

use App\Models\UserReadingProgress;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReadingController extends Controller
{
    
    public function updateProgress(Request $request)
    {
        $request->validate([
            'book_id'      => 'required|exists:books,id',
            'current_page' => 'required|integer|min:1',
        ]);

        $customerId = Auth::user()->customer->id;
        $book = Book::findOrFail($request->book_id);
        
        // التحقق من عدم تجاوز عدد صفحات الكتاب
        $page = ($request->current_page > $book->total_pages) ? $book->total_pages : $request->current_page;

        // تحديث أو إنشاء سجل تقدم القراءة
        $progress = UserReadingProgress::updateOrCreate(
            ['customer_id' => $customerId, 'book_id' => $request->book_id],
            ['last_page_read' => $page]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث تقدم القراءة بنجاح',
            'data' => [
                'current_page' => $progress->last_page_read,
                'is_completed' => $progress->last_page_read == $book->total_pages
            ]
        ]);
    }
}