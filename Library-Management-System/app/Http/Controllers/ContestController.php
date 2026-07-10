<?php

namespace App\Http\Controllers;

use App\Models\Contest;
use App\Models\ContestParticipant;
use App\Models\Notification;
use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ContestController extends Controller
{
    protected $pointsService;
    public function __construct(PointsService $pointsService)
    {
        $this->pointsService = $pointsService;
    }

    public function index()
    {
        $contests = Contest::where('end_date', '>=', now())->get();
        return response()->json($contests);
    }

    public function join(Request $request, $id)
    {
        $contest = Contest::findOrFail($id);
        if (now()->greaterThan($contest->end_date)) {
            return response()->json([
                'message' => 'عذراً,هذه المسابقة انتهت'
            ], 400);
        }
        $customerId = Auth::user()->id;
        $alreadyJoined = ContestParticipant::where('contest_id', $contest->id)
            ->where('customer_id', $customerId)
            ->exists();
        if ($alreadyJoined) {

            return response()->json([
                'message' => 'أنت مشترك بهذه المسابقة'
            ], 400);
        }
        $participant = ContestParticipant::create([
            'contest_id' => $contest->id,
            'customer_id' => $customerId,
            'current_progress' => 0,
            'status' => 'active'
        ]);
        return response()->json([
            'message' => 'تم الأنضمام للمسابقة بنجاح,بالتوفيق',
            'data' => $participant
        ], 201);
    }
    public function updateProgress(Request $request, $id)
    {
        $request->validate([
            'pages_read' => 'required|integer|min:1'
        ]);

        $customerId = Auth::user()->id;

        $participant = ContestParticipant::where('contest_id', $id)
            ->where('customer_id', $customerId)
            ->where('status', 'active')
            ->firstOrFail();

        $contest = $participant->contest;
        $newProgress = $participant->current_progress + $request->pages_read;


        if ($newProgress >= $contest->target_pages) {
            $newProgress = $contest->target_pages;
            $participant->status = 'completed';

            $reason = "مكافأة الفوز بمسابقة: " . $contest->title;
            $this->pointsService->addPoints($customerId, $contest->reward_points, 'earn', $reason);


            Notification::send(
                $customerId,
                Notification::TYPE_POINTS_EARNED,
                'مبروك! لقد فزت بالتحدي 🏆',
                "تهانينا! لقد أتممت قراءة الصفحات المطلوبة في تحدي ({$contest->title}) وحصلت على {$contest->reward_points} نقطة مكافأة!",
                [
                    'icon' => 'trophy_success',
                    'target_screen' => 'rewards_dashboard',
                    'contest_id' => $contest->id
                ]
            );
        } else {

            Notification::send(
                $customerId,
                Notification::TYPE_POINTS_EARNED,
                'تابع البطل! 📖',
                "لقد سجلت قراءة {$request->pages_read} صفحة جديدة في تحدي ({$contest->title}). متبقي لك فقط " . ($contest->target_pages - $newProgress) . " صفحة للنصر!",
                [
                    'icon' => 'book_reading',
                    'target_screen' => 'contest_details',
                    'contest_id' => $contest->id
                ]
            );
        }

        $participant->update([
            'current_progress' => $newProgress,
            'status' => $participant->status
        ]);

        return response()->json([
            'message' => 'تم تحديث تقدمك في المسابقة بنجاح',
            'data' => [
                'current_progress' => $participant->current_progress,
                'target_pages' => $contest->target_pages,
                'status' => $participant->status,
                'reward_points_earned' => $participant->status === 'completed' ? $contest->reward_points : 0
            ]
        ]);
    }
}
