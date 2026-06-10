<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AuthorController extends Controller
{
    use ApiResponse, NotifiesUsers;

    public function index(Request $request): JsonResponse
    {
        $authors = Author::select('id', 'name', 'birth_date', 'country')
            ->withCount('books')
            ->when($request->search, function ($query, $search) {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('country', 'like', "%{$search}%");
            })
            ->get();

        return $this->successResponse($authors);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'       => 'required|string|max:70|unique:authors,name',
            'birth_date' => 'nullable|date',
            'country'    => 'nullable|string|max:100',
        ]);

        $author = Author::create($validated);

        $this->notifySafe(
            $request->user()->id,
            'author_added',
            'إضافة مؤلف جديد ✍️',
            "تم إضافة المؤلف ({$author->name}) بنجاح إلى قاعدة البيانات.",
            ['icon' => 'author_success', 'target_screen' => 'authors_list', 'author_id' => $author->id]
        );

        return $this->successResponse($author, 'تم إضافة المؤلف بنجاح', 201);
    }

    public function show($id): JsonResponse
    {
        $author = Author::with(['books' => function ($q) {
            $q->withTrashed()->select('books.id', 'title', 'price', 'sale_price');
        }])->findOrFail($id);

        return $this->successResponse($author);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $author = Author::findOrFail($id);

        $validated = $request->validate([
            'name'       => 'sometimes|required|string|max:70|unique:authors,name,' . $author->id,
            'birth_date' => 'nullable|date',
            'country'    => 'nullable|string|max:100',
        ]);

        $author->update($validated);

        return $this->successResponse($author, 'تم تحديث بيانات المؤلف بنجاح');
    }

    public function destroy($id): JsonResponse
    {
        $author = Author::findOrFail($id);

        if ($author->books()->withTrashed()->exists()) {
            return $this->errorResponse('لا يمكن حذف هذا المؤلف لوجود كتب مرتبطة به في النظام.', 422);
        }

        $author->delete();

        return $this->successResponse(message: 'تم حذف المؤلف بنجاح');
    }
}
