<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Transaction;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    /**
     * عرض كل الكتب مع دعم البحث المتقدم
     */
    public function index(Request $request)
    {
        $filters = $request->only([
            'category_id',
            'author_id',
            'price_min',
            'price_max',
            'sale_min',
            'sale_max',
            'min_rating',
            'is_digital',
        ]);

        $query = Book::with(['authors', 'category'])
            ->withAvg('ratings as avg_rating', 'ratings.rate');

        if (!$request->user() || $request->user()->type !== 'admin') {
            $query->where('stock', '>', 0);
        }

        $query->when($request->search, function ($q, $search) {
            $q->where(function ($inner) use ($search) {
                $inner->where('title', 'like', "%{$search}%")
                    ->orWhere('ISBN', 'like', "%{$search}%");
            });
        });

        $query->when(!empty($filters), function ($q) use ($filters) {
            if (isset($filters['category_id']) && $filters['category_id'] !== '') {
                $q->where('category_id', $filters['category_id']);
            }

            if (isset($filters['price_min']) && $filters['price_min'] !== '') $q->where('price', '>=', $filters['price_min']);
            if (isset($filters['price_max']) && $filters['price_max'] !== '') $q->where('price', '<=', $filters['price_max']);

            if (isset($filters['sale_min']) && $filters['sale_min'] !== '') $q->where('sale_price', '>=', $filters['sale_min']);
            if (isset($filters['sale_max']) && $filters['sale_max'] !== '') $q->where('sale_price', '<=', $filters['sale_max']);

            if (isset($filters['is_digital']) && $filters['is_digital'] !== '') {
                $q->where('is_digital', filter_var($filters['is_digital'], FILTER_VALIDATE_BOOLEAN));
            }

            if (isset($filters['min_rating']) && $filters['min_rating'] !== '') {
                $q->having('avg_rating', '>=', $filters['min_rating']);
            }

            if (isset($filters['author_id']) && $filters['author_id'] !== '') {
                $q->whereHas('authors', function ($authQ) use ($filters) {
                    $authQ->where('authors.id', $filters['author_id']);
                });
            }
        });

        $books = $query->latest()->paginate(12);

        return response()->json([
            'status' => 'success',
            'data'   => $books
        ], 200);
    }
    /**
     * إضافة كتاب جديد
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'ISBN'            => 'required|string|size:13|unique:books,ISBN',
            'title'           => 'required|string|max:150',
            'price'           => 'required|numeric|min:0',
            'sale_price'      => 'required|numeric|min:0',
            'category_id'     => 'required|exists:categories,id',
            'authors'         => 'required|array',
            'authors.*'       => 'exists:authors,id',
            'stock'           => 'required|integer|min:0',
            'total_copies'    => 'required|integer|min:0',
            'borrow_duration' => 'nullable|integer',
            'authorship_date' => 'nullable|date',
            'is_digital'      => 'required|boolean',
            'cover'           => 'nullable|image|max:2048',
            'file_path'       => 'required_if:is_digital,1|nullable|file|mimes:pdf,epub|max:10240',
            'total_pages'     => 'nullable|integer',
        ]);

        return DB::transaction(function () use ($request, $validated) {

            $coverPath = $request->hasFile('cover')
                ? $request->file('cover')->store('covers', 'public')
                : null;

            $filePath = ($request->is_digital && $request->hasFile('file_path'))
                ? $request->file('file_path')->store('books_files', 'public')
                : null;

            $bookData = collect($validated)->except(['authors', 'cover', 'file_path'])->toArray();
            $bookData['cover'] = $coverPath;
            $bookData['file_path'] = $filePath;

            $book = Book::create($bookData);

            $book->authors()->attach($request->authors);

            $book->stockOperations()->create([
                'type'     => 'add',
                'quantity' => $validated['stock'],
            ]);

            // 7. 🔔 إشعار الأدمن بنجاح العملية
            try {
                Notification::send(
                    $request->user()->id,
                    'book_added',
                    'إضافة كتاب جديد 📚',
                    "تم إضافة الكتاب الجديد ({$book->title}) بنجاح بسعر إعارة {$book->price} وسعر بيع {$book->sale_price}.",
                    [
                        'icon' => 'book_success',
                        'target_screen' => 'book_details',
                        'book_id' => $book->id
                    ]
                );
            } catch (\Exception $e) {
                // تجاهل خطأ الإشعار لضمان إتمام العملية الأساسية
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم إضافة الكتاب بنجاح وتحديث المخزون',
                'data' => $book->load('authors', 'category')
            ], 201);
        });
    }

    /**
     * عرض تفاصيل كتاب محدد
     */
    public function show($id)
    {
        $book = Book::with(['authors', 'category'])
            ->withAvg('ratings as avg_rating', 'ratings.rate')
            ->withCount('ratings as total_reviews')
            ->findOrFail($id);

        $book->is_available = $book->stock > 0;

        if ($book->is_digital) {
            $book->has_file = !empty($book->file_path);
        }
        if ($book->is_digital && (!request()->user() || request()->user()->type !== 'admin')) {
            $book->makeHidden('file_path');
        }
        return response()->json([
            'status' => 'success',
            'data' => $book
        ]);
    }
    /**
     * تعديل كتاب
     */
    public function update(Request $request, Book $book)
    {
        $validated = $request->validate([
            'ISBN'            => 'sometimes|required|string|size:13|unique:books,ISBN,' . $book->id,
            'title'           => 'sometimes|required|string|max:150',
            'price'           => 'sometimes|required|numeric|min:0',
            'sale_price'      => 'sometimes|required|numeric|min:0',
            'category_id'     => 'sometimes|required|exists:categories,id',
            'authors'         => 'sometimes|required|array',
            'authors.*'       => 'exists:authors,id',
            'stock'           => 'sometimes|required|integer|min:0',
            'total_copies'    => 'sometimes|required|integer|min:0',
            'borrow_duration' => 'nullable|integer',
            'authorship_date' => 'nullable|date',
            'is_digital'      => 'sometimes|required|boolean',
            'cover'           => 'nullable|image|max:2048',
            'file_path'       => 'nullable|file|mimes:pdf,epub|max:10240',
            'total_pages'     => 'nullable|integer',
        ]);

        return DB::transaction(function () use ($request, $validated, $book) {

            if ($request->hasFile('cover')) {
                if ($book->cover) {
                    Storage::disk('public')->delete($book->cover);
                }
                $validated['cover'] = $request->file('cover')->store('covers', 'public');
            }

            $isDigital = $request->has('is_digital') ? $request->is_digital : $book->is_digital;
            if ($isDigital && $request->hasFile('file_path')) {
                if ($book->file_path) {
                    Storage::disk('public')->delete($book->file_path);
                }
                $validated['file_path'] = $request->file('file_path')->store('books_files', 'public');
            }

            if ($request->has('authors')) {
                $book->authors()->sync($request->authors);
            }

            $updateData = collect($validated)->except(['authors'])->toArray();
            $book->update($updateData);

            // . 🔔 إرسال إشعار تحديث ناجح
            try {
                Notification::send(
                    $request->user()->id,
                    'book_updated',
                    'تحديث بيانات كتاب 📝',
                    "تم تحديث بيانات كتاب ({$book->title}) والأسعار الجديدة بنجاح.",
                    [
                        'icon' => 'book_edit',
                        'target_screen' => 'book_details',
                        'book_id' => $book->id
                    ]
                );
            } catch (\Exception $e) {
                // تجاوز خطأ الإشعار
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم تحديث بيانات الكتاب بنجاح',
                'data' => $book->load('authors', 'category')
            ]);
        });
    }

    /**
     * حذف كتاب
     */
    public function destroy(Request $request, Book $book)
    {
        try {
            return DB::transaction(function () use ($request, $book) {

                $hasBills = \App\Models\BillDetail::where('book_id', $book->id)->exists();
                $hasTransactions = \App\Models\Transaction::where('book_id', $book->id)->exists();

                if ($hasBills || $hasTransactions) {
                    $book->delete();

                    $message = 'تم إخفاء الكتاب من المتجر بنجاح للحفاظ على سجلات الفواتير المرتبطة به.';
                    $type = 'book_hidden';
                } else {

                    $book->authors()->detach();
                    $book->stockOperations()->delete();

                    if ($book->cover) Storage::disk('public')->delete($book->cover);
                    if ($book->file_path) Storage::disk('public')->delete($book->file_path);

                    $book->forceDelete();

                    $message = 'تم حذف الكتاب وملفاته نهائياً من النظام لعدم وجود فواتير مرتبطة به.';
                    $type = 'book_deleted_permanently';
                }

                // 2. 🔔 إرسال الإشعار الموحد
                try {
                    Notification::send(
                        $request->user()->id,
                        'book_removal',
                        'تحديث حالة كتاب ⚠️',
                        "الإجراء: {$message} اسم الكتاب: ({$book->title})",
                        ['icon' => 'book_delete', 'target_screen' => 'books_dashboard']
                    );
                } catch (\Exception $e) {
                }

                return response()->json([
                    'status' => 'success',
                    'message' => $message
                ]);
            });
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'حدث خطأ غير متوقع أثناء معالجة الحذف: ' . $e->getMessage()
            ], 500);
        }
    }
    /**
     * الإحصائيات: الكتب الأكثر مبيعاً)
     */
    public function getTopSellingBooks()
    {
        $topBooks = \App\Models\BillDetail::query()
            ->with(['book' => function ($query) {
                $query->withTrashed();
            }])
            ->select('book_id', DB::raw('SUM(quantity) as total_sold'))
            ->groupBy('book_id')
            ->orderByDesc('total_sold')
            ->take(5)
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'قائمة الكتب الأكثر مبيعاً بناءً على تفاصيل الفواتير',
            'data' => $topBooks->map(function ($item) {
                return [
                    'book_id'    => $item->book_id,
                    'book_title' => $item->book->title ?? 'كتاب غير مدرج حالياً',
                    'units_sold' => (int) $item->total_sold,
                    'is_active'  => $item->book ? !$item->book->trashed() : false
                ];
            })
        ]);
    }


    /**
     * الإحصائيات: الكتب الأكثر استعارة
     */
    public function topBorrowed(Request $request)
    {
        $count = min($request->integer('count', 10), 50);
        $books = Book::withTrashed()
            ->withCount(['transactions' => function ($query) {
                $query->whereIn('status', ['received', 'returned']);
            }])
            ->orderByDesc('transactions_count')
            ->take($count)
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'قائمة الكتب الأكثر استعارة وطلباً',
            'data' => $books->map(function ($book) {
                return [
                    'id' => $book->id,
                    'title' => $book->title,
                    'borrow_count' => $book->transactions_count,
                    'is_active' => !$book->trashed(),
                    'current_stock' => $book->stock,
                ];
            })
        ]);
    }

    /**
     * إضافة أو تحديث تقييم كتاب بشرط الاستعارة المسبقة والإرجاع)
     */
    public function rateBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
            'rate'    => ['required', 'integer', 'min:1', 'max:5'],
        ]);

        $user = $request->user();

        if (!$user->customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، يجب أن يكون لديك حساب عميل فعال لتتمكن من التقييم'
            ], 403);
        }

        $customerId = $user->customer->id;
        $bookId     = $request->book_id;

        $hasPurchased = \App\Models\Transaction::where('user_id', $user->id)
            ->where('book_id', $bookId)
            ->where('type', 'buy')
            ->where('status', 'sold')
            ->exists();

        $hasReturned = \App\Models\Transaction::where('user_id', $user->id)
            ->where('book_id', $bookId)
            ->where('type', 'borrow')
            ->where('status', 'returned')
            ->exists();

        if (!$hasPurchased && !$hasReturned) {
            return response()->json([
                'status' => 'error',
                'message' => 'يمكنك تقييم الكتب التي قمت بشرائها أو استعارتها وإعادتها فقط.'
            ], 403);
        }


        \Illuminate\Support\Facades\DB::table('ratings')->updateOrInsert(
            ['book_id' => $bookId, 'customer_id' => $customerId],
            [
                'rate' => $request->rate,
                'updated_at' => now(),
                'created_at' => \Illuminate\Support\Facades\DB::raw('IFNULL(created_at, NOW())')
            ]
        );

        $book = Book::withTrashed()->find($bookId);

        // 🔔 إرسال إشعار النجاح للمستخدم
        try {
            Notification::send(
                $user->id,
                'book_rated',
                'شكراً لتقييمك المتميز ⭐',
                "تم حفظ تقييمك ({$request->rate} نجوم) لكتاب ({$book->title}) بنجاح.",
                [
                    'icon' => 'rate_success',
                    'target_screen' => 'book_details',
                    'book_id' => $bookId
                ]
            );
        } catch (\Exception $e) {
            // تخطي خطأ الإشعارات حتى لا تتوقف العملية الأساسية
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل تقييمك بنجاح، شكراً لمساهمتك!'
        ]);
    }
}
