<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    use ApiResponse, NotifiesUsers;

    public function index(): JsonResponse
    {
        $categories = Category::select('id', 'name')
            ->withCount(['books' => function ($query) {
                $query->whereNull('deleted_at');
            }])
            ->get();

        return $this->successResponse($categories);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
        ]);

        $category = Category::create($validated);

        $this->notifySafe(
            $request->user()->id,
            'category_created',
            'إضافة تصنيف جديد 📂',
            "تم إضافة التصنيف الجديد ({$category->name}) بنجاح إلى النظام.",
            ['icon' => 'category_success', 'target_screen' => 'categories_dashboard', 'category_id' => $category->id]
        );

        return $this->successResponse($category, 'تم إضافة التصنيف بنجاح', 201);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name,' . $category->id,
        ]);

        $category->update($validated);

        return $this->successResponse($category, 'تم تحديث اسم التصنيف بنجاح');
    }

    public function destroy(Request $request, $id): JsonResponse
    {
        $category = Category::findOrFail($id);

        if ($category->books()->withTrashed()->exists()) {
            return $this->errorResponse('لا يمكن حذف التصنيف لأنه يحتوي على كتب مسجلة. قم بنقل الكتب أولاً.', 422);
        }

        $category->delete();

        return $this->successResponse(message: 'تم حذف التصنيف بنجاح');
    }
}
