<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class AuthorController extends Controller
{
    /**
     * عرض قائمة المؤلفين مع عدد كتبهم والبحث
     */
    public function index(Request $request): JsonResponse
    {
        $authors = Author::select('id', 'name', 'birth_date', 'country')
            ->withCount('books')
            ->when($request->search, function ($query, $search) {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('country', 'like', "%{$search}%");
            })
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $authors
        ]);
    }

    /**
     * إضافة مؤلف جديد
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'       => 'required|string|max:70|unique:authors,name',
            'birth_date' => 'nullable|date',
            'country'    => 'nullable|string|max:100',
        ]);

        $author = Author::create($validated);

        try {
            Notification::send(
                $request->user()->id,
                'author_added',
                'إضافة مؤلف جديد ✍️',
                "تم إضافة المؤلف ({$author->name}) بنجاح إلى قاعدة البيانات.",
                [
                    'icon' => 'author_success',
                    'target_screen' => 'authors_list',
                    'author_id' => $author->id
                ]
            );
        } catch (\Exception $e) {
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم إضافة المؤلف بنجاح',
            'data' => $author
        ], 201);
    }

    /**
     * عرض تفاصيل مؤلف مع قائمة كتبه
     */
    public function show($id): JsonResponse
    {
        $author = Author::with(['books' => function ($q) {
            $q->withTrashed()->select('books.id', 'title', 'price', 'sale_price');
        }])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => $author
        ]);
    }

    /**
     * تحديث بيانات مؤلف
     */
    public function update(Request $request, $id): JsonResponse
    {
        $author = Author::findOrFail($id);

        $validated = $request->validate([
            'name'       => 'sometimes|required|string|max:70|unique:authors,name,' . $author->id,
            'birth_date' => 'nullable|date',
            'country'    => 'nullable|string|max:100',
        ]);

        $author->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث بيانات المؤلف بنجاح',
            'data' => $author
        ]);
    }

    /**
     * حذف مؤلف
     */
    public function destroy($id): JsonResponse
    {
        $author = Author::findOrFail($id);

        if ($author->books()->withTrashed()->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن حذف هذا المؤلف لوجود كتب مرتبطة به في النظام.'
            ], 422);
        }

        $author->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف المؤلف بنجاح'
        ]);
    }
}
