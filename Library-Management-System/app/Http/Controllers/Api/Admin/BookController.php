<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    //  عرض كل الكتب
    public function index(Request $request)
    {
        $books = Book::with('authors', 'category')
            ->when($request->search, function ($query, $search) {
                $query->where('title', 'like', "%{$search}%")
                      ->orWhere('ISBN', 'like', "%{$search}%");
            })
            ->paginate(10);

        return response()->json($books);
    }


    // إضافة كتاب جديد
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

            return response()->json([
                'status' => 'success',
                'message' => 'تم إضافة الكتاب بنجاح مع تسجيل المخزون والمؤلفين',
                'data' => $book->load('authors', 'category')
            ], 201);
        });
    }

    //  عرض تفاصيل كتاب محدد
    public function show($id)
    {
        $book = Book::with('authors', 'category')->findOrFail($id);
        return response()->json($book);
    }

    //  تعديل كتاب
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

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث بيانات الكتاب بنجاح',
            'data' => $book->load('authors', 'category')
        ]);
    });
}

    //  حذف كتاب
    public function destroy($id)
    {
        $book = Book::findOrFail($id);

        if ($book->cover) Storage::disk('public')->delete($book->cover);
        if ($book->file_path) Storage::disk('public')->delete($book->file_path);

        $book->delete();
        return response()->json(['message' => 'تم حذف الكتاب بنجاح']);
    }

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
}
