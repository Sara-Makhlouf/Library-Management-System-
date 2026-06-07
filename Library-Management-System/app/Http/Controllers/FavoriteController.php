<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    // عرض قائمة الكتب المفضلة للزبون الحالي
    public function index()
    {
        $customer = Auth::user()->customer;
        $favorites = $customer->favorites()->with('category')->get();

        return response()->json([
            'status' => 'success',
            'data' => $favorites
        ]);
    }

    // إضافة أو حذف كتاب من المفضلة
    public function toggle(Request $request)
    {
        $request->validate(['book_id' => 'required|exists:books,id']);

        $customer = Auth::user()->customer;

        $result = $customer->favorites()->toggle($request->book_id);

        $status = count($result['attached']) > 0 ? 'added' : 'removed';

        return response()->json([
            'status' => 'success',
            'message' => $status == 'added' ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة',
            'action' => $status
        ]);
    }
}
