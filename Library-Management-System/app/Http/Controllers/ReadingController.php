<?php

namespace App\Http\Controllers;

use App\Models\Notification;
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
        if (isset($result['points_earned']) && $result['points_earned'] > 0){
        Notification::send(
            $customer->id,
            Notification::TYPE_POINTS_EARNED,
            'مبروك! كسبت نقاطاً جديدة 🎉',
            "تمت إضافة {$result['points_earned']} نقطة إلى محفظتك لتقدمك في القراءة.",
            [
                'icon' => 'coins_icon',
                'target_screen' => 'wallet',
                'earned_amount' => $result['points_earned']
            ]
        );
        }
        return response()->json($result);
    }
}

