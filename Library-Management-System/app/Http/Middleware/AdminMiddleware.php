<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::check()) {
            return response()->json([
                'status' => 'error',
                'message' => 'غير مسجل دخول'
            ], 401);
        }

        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json([
                'status' => 'error',
                'message' => 'ليس لديك صلاحيات إدارية'
            ], 403);
        }

        return $next($request);
    }
}
