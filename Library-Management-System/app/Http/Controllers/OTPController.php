<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class OTPController extends Controller
{

    public function sendOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string'
        ]);

        $phone = $request->phone;

        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('phone_otps')->updateOrInsert(
            ['phone' => $phone],
            [
                'otp_code' => $otp,
                'expires_at' => Carbon::now()->addMinutes(5),
                'updated_at' => Carbon::now()
            ]
        );

        $yasendUrl = env('YASEND_URL', 'http://localhost:3000');
        $apiKey = env('YASEND_API_KEY', 'YOUR_API_KEY');

        try {
            $response = Http::withHeaders([
                'x-api-key' => $apiKey
            ])->post("{$yasendUrl}/api/send-message", [
                'phone' => $phone,
                'message' => "رمز التحقق الخاص بك هو: {$otp}"
            ]);

            return response()->json([
                'status' => true,
                'message' => 'تم إرسال رمز الـ OTP بنجاح عبر الواتساب'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'فشل إرسال الرسالة، تأكدي من تشغيل سيرفر YASend',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public static function verifyOtp($phone, $code)
    {
        $record = DB::table('phone_otps')
            ->where('phone', $phone)
            ->where('otp_code', $code)
            ->where('expires_at', '>', Carbon::now())
            ->first();

        if ($record) {
            DB::table('phone_otps')->where('phone', $phone)->delete();
            return true;
        }

        return false;
    }
}
