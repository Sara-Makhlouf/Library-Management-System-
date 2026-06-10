<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use App\Traits\ResolvesCustomer;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    use ApiResponse, ResolvesCustomer;

    public function index(): JsonResponse
    {
        $customer = Auth::user()->customer;
        $favorites = $customer->favorites()->with('category')->get();

        return $this->successResponse($favorites);
    }

    public function toggle(Request $request): JsonResponse
    {
        $request->validate(['book_id' => 'required|exists:books,id']);

        $customer = Auth::user()->customer;

        $result = $customer->favorites()->toggle($request->book_id);

        $status = count($result['attached']) > 0 ? 'added' : 'removed';

        return $this->successResponse(
            ['action' => $status],
            $status == 'added' ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'
        );
    }
}
