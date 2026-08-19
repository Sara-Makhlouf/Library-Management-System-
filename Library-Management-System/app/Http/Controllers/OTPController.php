<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;

class OTPController extends Controller
{
    public function sendOtp(Request $request)
    {
        // 1. تغيير التحقق ليصبح بريد إلكتروني بدلاً من الهاتف
        $request->validate([
            'email' => 'required|email'
        ]);

        $email = $request->email;

        // توليد كود OTP مكون من 6 أرقام
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // 2. تحديث جدول البيانات (يفضل تغيير اسم الجدول أو استخدام عمود email)
        DB::table('email_otps')->updateOrInsert(
            ['email' => $email], // أو يمكنك إبقاؤها 'email' لترسل الإيميل داخل نفس العمود
            [
                'otp_code' => $otp,
                'expires_at' => Carbon::now()->addMinutes(5),
                'updated_at' => Carbon::now()
            ]
        );

        try {
            // 3. إرسال الإيميل مجاناً باستخدام ميزة Mail في لارافيل
            Mail::raw("رمز التحقق الخاص بك هو: {$otp}", function ($message) use ($email) {
                $message->to($email)
                    ->subject('رمز التحقق (OTP)');
            });

            return response()->json([
                'status' => true,
                'message' => 'تم إرسال رمز الـ OTP بنجاح إلى البريد الإلكتروني'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'فشل إرسال البريد الإلكتروني',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 4. تعديل دالة التحقق لتستقبل email بدلاً من email
    public static function verifyOtp($email, $code)
    {
        $record = DB::table('email_otps')
            ->where('email', $email)
            ->where('otp_code', $code)
            ->where('expires_at', '>', Carbon::now())
            ->first();

        if ($record) {
            DB::table('email_otps')->where('email', $email)->delete();
            return true;
        }

        return false;
    }
}
