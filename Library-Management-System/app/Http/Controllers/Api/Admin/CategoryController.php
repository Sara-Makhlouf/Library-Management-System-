<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Notification; 
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function list(): JsonResponse
    {
        $categories = Category::select('id', 'name')->get();

        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
        ]);

        $category = Category::create($validated);

        // 🔔 إضافة دالة الإشعار الموحدة فقط عند إنشاء تصنيف جديد بنجاح
        try {
            Notification::send(
                $request->user()->id, // معرف الآدمن الحالي من الـ Token
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
            // تجاوز أي خطأ طارئ لضمان استقرار العملية
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم إضافة التصنيف بنجاح',
            'data' => $category
        ], 201);
    }
}