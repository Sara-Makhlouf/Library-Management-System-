<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Author;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AuthorController extends Controller
{
    public function index(): JsonResponse
    {
        $authors = Author::select('id', 'name', 'birth_date', 'country')->get();
        return response()->json([
            'status' => 'success',
            'data' => $authors
        ]);
    }

    public function store(Request $request): JsonResponse
    {

        $validated = $request->validate([
            'name'       => 'required|string|max:70|unique:authors,name',
            'birth_date' => 'nullable|date',
            'country'    => 'nullable|string|max:100',
        ]);

        $author = Author::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'تم إضافة المؤلف بنجاح',
            'data' => $author
        ], 201);
    }
}
