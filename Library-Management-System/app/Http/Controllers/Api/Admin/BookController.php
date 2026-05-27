<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Transaction;
use App\Models\Notification; // استدعاء الموديل الموحد هنا ✅
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    /**
     * عرض كل الكتب مع دعم البحث المتقدم (دمج بين ولاء ومصطفى)
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

        $books = Book::with(['authors', 'category'])
            ->withAvg('rating as avg_rating', 'rate')
            // تفعيل فلاتر البحث والتحقق من كلمة البحث النصية عند ولاء
            ->when($request->search, function ($query, $search) {
                $query->where('title', 'like', "%{$search}%")
                      ->orWhere('ISBN', 'like', "%{$search}%");
            })
            // تفعيل الفلاتر المتقدمة الخاصة بمصطفى في حال وجودها
            ->when(!empty($filters), function ($query) use ($filters) {
                if (isset($filters['category_id'])) $query->where('category_id', $filters['category_id']);
                if (isset($filters['price_min'])) $query->where('price', '>=', $filters['price_min']);
                if (isset($filters['price_max'])) $query->where('price', '<=', $filters['price_max']);
            })
            ->paginate(10);

        return response()->json($books);
    }

    /**
     * إضافة كتاب جديد (كود ولاء)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'ISBN'            => 'required|string|size:13|unique:books,ISBN',
            'title'           => 'required|string|max:150',
            'price'           => 'required|numeric|min:0',
            'mortgage'        => 'nullable|numeric|min:0',
            'category_id'     => 'required|exists:categories,id',
            'authors'         => 'required|array',
            'stock'           => 'required|integer|min:0',
            'total_copies'    => 'required|integer|min:0',
            'borrow_duration' => 'nullable|integer',
            'is_digital'      => 'required|boolean',
            'cover'           => 'nullable|image|max:2048',
            'file_path'       => 'nullable|file|mimes:pdf,epub|max:10240',
            'total_pages'     => 'nullable|integer',
        ]);

        return DB::transaction(function () use ($request, $validated) {

            $coverPath = $request->hasFile('cover')
                ? $request->file('cover')->store('covers', 'public')
                : null;

            $filePath = ($request->is_digital && $request->hasFile('file_path'))
                ? $request->file('file_path')->store('books_files', 'public')
                : null;

            $book = Book::create(array_merge($validated, [
                'cover'     => $coverPath,
                'file_path' => $filePath,
            ]));
            
            $book->authors()->attach($request->authors);
            
            $book->stockOperations()->create([
                'operation_type' => 'addition',
                'quantity'       => $request->stock,
                'note'           => 'إضافة مخزون أولية عند إنشاء الكتاب',
            ]);

            // 🔔 إشعار موحد: عند إضافة كتاب جديد
            try {
                Notification::send(
                    $request->user()->id,
                    'book_added',
                    'إضافة كتاب جديد 📚',
                    "تم إضافة الكتاب الجديد ({$book->title}) إلى المكتبة المتاحة بنجاح.",
                    [
                        'icon' => 'book_success',
                        'target_screen' => 'book_details',
                        'book_id' => $book->id
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز الخطأ لضمان استقرار المعاملة
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم إضافة الكتاب بنجاح مع تسجيل المخزون والمؤلفين',
                'data' => $book->load('authors', 'category')
            ], 201);
        });
    }

    /**
     * عرض تفاصيل كتاب محدد (دمج: بيانات ولاء + حساب متوسط التقييم لمصطفى)
     */
    public function show($id)
    {
        $book = Book::with(['authors', 'category'])->findOrFail($id);
        $book->loadAvg('rating as avg_rating', 'rate');
        
        return response()->json($book);
    }

    /**
     * تعديل كتاب (كود ولاء)
     */
    public function update(Request $request, Book $book)
    {
        $validated = $request->validate([
            'ISBN'            => 'required|string|size:13|unique:books,ISBN,' . $book->id,
            'title'           => 'required|string|max:150',
            'price'           => 'required|numeric|min:0',
            'mortgage'        => 'nullable|numeric|min:0',
            'category_id'     => 'required|exists:categories,id',
            'authors'         => 'required|array',
            'stock'           => 'required|integer|min:0',
            'total_copies'    => 'required|integer|min:0',
            'borrow_duration' => 'nullable|integer',
            'is_digital'      => 'required|boolean',
            'cover'           => 'nullable|image|max:2048',
            'file_path'       => 'nullable|file|mimes:pdf,epub|max:10240',
            'total_pages'     => 'nullable|integer',
        ]);

        return DB::transaction(function () use ($request, $validated, $book) {

            if ($request->hasFile('cover')) {
                if ($book->cover) Storage::disk('public')->delete($book->cover);
                $validated['cover'] = $request->file('cover')->store('covers', 'public');
            }

            if ($request->is_digital && $request->hasFile('file_path')) {
                if ($book->file_path) Storage::disk('public')->delete($book->file_path);
                $validated['file_path'] = $request->file('file_path')->store('books_files', 'public');
            }

            $book->update($validated);
            $book->authors()->sync($request->authors);

            // 🔔 إشعار موحد: عند تعديل بيانات الكتاب
            try {
                Notification::send(
                    $request->user()->id,
                    'book_updated',
                    'تحديث بيانات كتاب 📝',
                    "تم تحديث بيانات وملف كتاب ({$book->title}) بنجاح في لوحة التحكم.",
                    [
                        'icon' => 'book_edit',
                        'target_screen' => 'book_details',
                        'book_id' => $book->id
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز الخطأ لضمان استقرار المعاملة
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم تحديث بيانات الكتاب بنجاح',
                'data' => $book->load('authors', 'category')
            ]);
        });
    }

    /**
     * حذف كتاب (كود ولاء)
     */
    public function destroy(Request $request, $id)
    {
        $book = Book::findOrFail($id);

        if ($book->cover) Storage::disk('public')->delete($book->cover);
        if ($book->file_path) Storage::disk('public')->delete($book->file_path);

        $bookTitle = $book->title;
        $book->delete();

        // 🔔 إشعار موحد: عند حذف الكتاب من النظام
        try {
            Notification::send(
                $request->user()->id,
                'book_deleted',
                'حذف كتاب من المكتبة ⚠️',
                "تم حذف كتاب ({$bookTitle}) وملفاته المرفقة نهائياً من النظام.",
                [
                    'icon' => 'book_delete',
                    'target_screen' => 'books_dashboard'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json(['message' => 'تم حذف الكتاب بنجاح']);
    }

    /**
     * الإحصائيات: الكتب الأكثر مبيعاً (كود ولاء)
     */
    public function getTopSellingBooks()
    {
        $topBooks = \App\Models\BillDetail::select('book_id', DB::raw('SUM(quantity) as total_sold'))
            ->with('book:id,title')
            ->groupBy('book_id')
            ->orderBy('total_sold', 'desc')
            ->take(5)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $topBooks->map(function($item) {
                return [
                    'book_title' => $item->book->title ?? 'كتاب غير معروف',
                    'units_sold' => (int)$item->total_sold
                ];
            })
        ]);
    }

    /**
     * الإحصائيات: الكتب الأكثر استعارة (كود مصطفى)
     */
    public function topBorrowed(Request $request)
    {
        $count = min($request->integer('count', 10), 50);

        $books = Book::withCount('transactions')
            ->orderByDesc('transactions_count')
            ->take($count)
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'الكتب الأكثر استعارة وشيوعاً',
            'data' => $books
        ]);
    }

    /**
     * إضافة أو تحديث تقييم كتاب بشرط الاستعارة المسبقة والإرجاع (كود مصطفى)
     */
    public function rateBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
            'rate'    => ['required', 'integer', 'min:1', 'max:5'],
        ]);

        // التحقق من وجود حساب عميل مرتبط بالمستخدم الحالي
        if (!$request->user()->customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مسجل كعميل في النظام لتتمكن من التقييم'
            ], 403);
        }

        $customerId = $request->user()->customer->id;
        $bookId     = $request->book_id;

        // التحقق من الاستعارة المسبقة والإرجاع
        $hasBorrowed = Transaction::whereHas('bill', function ($q) use ($customerId) {
                $q->where('customer_id', $customerId);
            })
            ->where('book_id', $bookId)
            ->where('status', 'returned')
            ->exists();

        if (!$hasBorrowed) {
            return response()->json([
                'status' => 'error',
                'message' => 'يجب استعارة الكتاب وإعادته أولاً حتى تتمكن من تقييمه'
            ], 403);
        }

        DB::table('ratings')->updateOrInsert(
            ['book_id' => $bookId, 'customer_id' => $customerId],
            ['rate' => $request->rate, 'updated_at' => now(), 'created_at' => now()]
        );

        $book = Book::find($bookId);

        // 🔔 إشعار موحد: شكر العميل عند تسجيل تقييمه للكتاب
        try {
            Notification::send(
                $request->user()->id,
                'book_rated',
                'شكراً لتقييمك المتميز ⭐',
                "تم حفظ تقييمك المكون من ({$request->rate} نجوم) لكتاب ({$book->title}) بنجاح.",
                [
                    'icon' => 'rate_success',
                    'target_screen' => 'book_details',
                    'book_id' => $bookId
                ]
            );
        } catch (\Exception $e) {
            // تجاوز الخطأ
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل تقييمك بنجاح'
        ]);
    }
}