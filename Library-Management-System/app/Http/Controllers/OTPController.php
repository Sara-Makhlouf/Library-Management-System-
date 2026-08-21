<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;

class OTPController extends Controller
{
    /**
     * Send OTP to email
     */
    public function sendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = strtolower(trim($request->email));

        $otp = str_pad(
            random_int(0, 999999),
            6,
            '0',
            STR_PAD_LEFT
        );

        DB::table('email_otps')->updateOrInsert(
            ['email' => $email],
            [
                'otp_code' => $otp,
                'expires_at' => Carbon::now()->addMinutes(5),
                'updated_at' => Carbon::now(),
            ]
        );

        try {
            Mail::raw(
                "رمز التحقق الخاص بك هو: {$otp}",
                function ($message) use ($email) {
                    $message
                        ->to($email)
                        ->subject('رمز التحقق (OTP)');
                }
            );

            return response()->json([
                'status' => true,
                'message' => 'تم إرسال رمز الـ OTP بنجاح إلى البريد الإلكتروني',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'فشل إرسال البريد الإلكتروني',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
    /**
     * Verify OTP
     */
    public static function verifyOtp($email, $code)
    {
        $email = strtolower(trim($email));

        $record = DB::table('email_otps')
            ->where('email', $email)
            ->where('otp_code', $code)
            ->where('expires_at', '>', Carbon::now())
            ->first();

        if ($record) {
            DB::table('email_otps')
                ->where('email', $email)
                ->delete();

            return true;
        }

        return false;
    }
}
