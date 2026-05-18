<?php

namespace App\Http\Controllers;

use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReadingController extends Controller
{
    protected $PointsService;
    public function  __construct(PointsService $pointsService)
    {
        $this->PointsService = $pointsService;
    }
    public function updateProgress(Request $request)
    {
        $request->validate([
            'book_id' => 'required|exists:books,id',
            'current_page' => 'required|integer|min:1',
        ]);
        $customer = Auth::user()->customer;
        $result = $this->PointsService->updateProgressAndEarnPoints(
            $customer->id,
            $request->book_id,
            $request->current_page
        );
        return response()->json($result);
    }
}
