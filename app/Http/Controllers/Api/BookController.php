<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BookController extends Controller
{
    /**
     * البحث والتصفح
     * يدعم: title, price_min, price_max, category_id, author_id, min_rating
     */
    public function index(Request $request)
    {
        $filters = $request->only([
            'title',
            'category_id',
            'author_id',
            'price_min',
            'price_max',
            'min_rating',
        ]);

        $books = Book::with(['category', 'authors'])
            ->withAvg('rating as avg_rating', 'rate')
            ->search($filters)
            ->paginate(10);

        return apiSuccess('نتائج الكتب', $books);
    }

    /**
     * عرض تفاصيل كتاب واحد
     */
    public function show(Book $book)
    {
        $book->load(['authors', 'category']);
        $book->loadAvg('rating as avg_rating', 'rate');

        return apiSuccess('تفاصيل الكتاب', $book);
    }

    /**
     * الكتب الأكثر استعارة
     */
    public function topBorrowed(Request $request)
    {
        $count = min($request->integer('count', 10), 50);

        $books = Book::withCount('transactions')
            ->orderByDesc('transactions_count')
            ->take($count)
            ->get();

        return apiSuccess('الكتب الأكثر شيوعاً', $books);
    }

    /**
     * إضافة أو تحديث تقييم كتاب
     * الشرط: يجب أن يكون العميل قد استعار الكتاب وأعاده
     */
    public function rateBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
            'rate'    => ['required', 'integer', 'min:1', 'max:5'],
        ]);

        $customerId = $request->user()->customer->id;
        $bookId     = $request->book_id;

        // التحقق من الاستعارة المسبقة والإرجاع
        $hasBorrowed = Transaction::whereHas('bill', function ($q) use ($customerId) {
                $q->where('customer_id', $customerId);
            })
            ->where('book_id', $bookId)
            ->where('status', 'returned')
            ->exists();

        if (! $hasBorrowed) {
            return apiError('يجب استعارة الكتاب وإعادته أولاً حتى تتمكن من تقييمه', 403);
        }

        DB::table('ratings')->updateOrInsert(
            ['book_id' => $bookId, 'customer_id' => $customerId],
            ['rate' => $request->rate, 'updated_at' => now(), 'created_at' => now()]
        );

        return apiSuccess('تم تسجيل تقييمك بنجاح');
    }
}