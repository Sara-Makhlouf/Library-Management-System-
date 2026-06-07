<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    /**
     * عرض قائمة التصنيفات مع عدد الكتب النشطة في كل منها
     */
    public function index(): JsonResponse
    {

        $categories = Category::select('id', 'name')
            ->withCount(['books' => function ($query) {
                $query->whereNull('deleted_at');
            }])
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }

    /**
     * إضافة تصنيف جديد
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
        ]);

        $category = Category::create($validated);

        try {
            Notification::send(
                $request->user()->id,
                'category_created',
                'إضافة تصنيف جديد 📂',
                "تم إضافة التصنيف الجديد ({$category->name}) بنجاح إلى النظام.",
                [
                    'icon' => 'category_success',
                    'target_screen' => 'categories_dashboard',
                    'category_id' => $category->id
                ]
            );
        } catch (\Exception $e) {
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم إضافة التصنيف بنجاح',
            'data' => $category
        ], 201);
    }

    /**
     * تحديث بيانات تصنيف
     */
    public function update(Request $request, $id): JsonResponse
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name,' . $category->id,
        ]);

        $category->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث اسم التصنيف بنجاح',
            'data' => $category
        ]);
    }

    /**
     * حذف تصنيف
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $category = Category::findOrFail($id);

        if ($category->books()->withTrashed()->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن حذف التصنيف لأنه يحتوي على كتب مسجلة. قم بنقل الكتب أولاً.'
            ], 422);
        }

        $category->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف التصنيف بنجاح'
        ]);
    }
}
