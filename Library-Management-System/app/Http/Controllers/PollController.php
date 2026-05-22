<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\PollOption;
use App\Models\PollVote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class PollController extends Controller
{
    public function index()
    {
        $polls = PollOption::all()->groupBy('question');
        return response()->json($polls);
    }
    public function vote(Request $request)
    {
        $request->validate([
            'poll_option_id' => 'required|exists:poll_options,id',
        ]);
        $customerId = Auth::user()->id;
        $option = PollOption::findOrFail($request->poll_option_id);
        $alreadyVoted = PollVote::where('customer_id', $customerId)
            ->whereHas('option', function ($query) use ($option) {
                $query->where('question', $option->question);
            })->exists();

        if ($alreadyVoted) {
            return response()->json(['message' => 'عذراً، لقد قمت بالتصويت على هذا الاستطلاع مسبقاً.'], 400);
        }


        DB::transaction(function () use ($option, $customerId) {

            PollVote::create([
                'poll_option_id' => $option->id,
                'customer_id' => $customerId,
            ]);


            $option->increment('votes_count');
        });


        Notification::send(
            $customerId,
            Notification::TYPE_POINTS_EARNED,
            'شكراً على مشاركتك! 🗳️',
            "تم تسجيل صوتك بنجاح في استطلاع رأي القراء حول: ({$option->question}). رأيك يصنع الفرق معنا!",
            [
                'icon' => 'vote_success',
                'target_screen' => 'polls_dashboard',
                'option_id' => $option->id
            ]
        );

        return response()->json([
            'message' => 'تم تسجيل صوتك بنجاح، شكراً للمشاركة',
            'data' => [
                'option' => $option->option_text,
                'current_votes' => $option->votes_count
            ]
        ], 201);
    }
}
