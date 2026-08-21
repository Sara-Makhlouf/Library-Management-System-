<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Models\Notification;
use App\Services\PointsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\OTPController;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    protected $pointsService;

    public function __construct(PointsService $pointsService)
    {
        $this->pointsService = $pointsService;
    }

    /**
     * تسجيل زبون جديد
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name'        => ['required', 'string', 'max:255'],
            'email'       => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password'    => ['required', 'confirmed', 'min:8'],
            'gender'      => ['required', 'in:M,F'],
            'phone'       => ['required', 'digits:10', 'unique:customers,phone'],
            'DOB'         => ['required', 'date', 'before:today'],
            'lang'        => ['sometimes', 'in:ar,en'],
            'avatar'      => ['nullable', 'image', 'max:2048'],
            'fcm_token'   => ['nullable', 'string'],
            'otp_code'    => ['required', 'string'],
        ]);

        // التحقق من OTP باستخدام البريد الإلكتروني بدلاً من الهاتف
        if (!OTPController::verifyOtp($validated['email'], $validated['otp_code'])) {
            return response()->json([
                'status'  => 'error',
                'message' => 'رمز التحقق (OTP) غير صحيح أو منتهي الصلاحية.'
            ], 422);
        }

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('customer-avatars', 'public');
        }

        $user = DB::transaction(function () use ($validated, $avatarPath) {

            $user = User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => bcrypt($validated['password']),
                'type'     => 'customer',
            ]);

            $customer = $user->customer()->create([
                'name'      => $validated['name'],
                'gender'    => $validated['gender'],
                'phone'     => $validated['phone'],
                'DOB'       => $validated['DOB'],
                'lang'      => $validated['lang'] ?? 'ar',
                'avatar'    => $avatarPath,
                'fcm_token' => $validated['fcm_token'] ?? null,
            ]);

            if ($user->type === 'customer') {
                try {
                    $this->pointsService->addPoints($customer->id, 50, 'earn', 'هدية ترحيبية بمناسبة الانضمام للتطبيق 🎉');
                } catch (\Throwable $e) {
                    // تجاوز الخطأ لضمان استقرار التسجيل
                    Log::error('Points Service Error: ' . $e->getMessage());
                }
            }

            try {
                Notification::send(
                    $customer->id,
                    'welcome_notification',
                    'أهلاً بك يا ' . $validated['name'] . '! 🎉',
                    'تم إنشاء حسابك بنجاح. استمتع برحلتك الثقافية معنا.',
                    ['icon' => 'welcome_user', 'target_screen' => 'home_dashboard']
                );
            } catch (\Throwable $e) {
                // \Throwable بدل \Exception عشان يلقط كمان TypeError وأي Error تانية
                // جاية من FCMService، وما يخلي التسجيل نفسه ينكسر بسببها
                Log::error('Notification Error: ' . $e->getMessage());
            }

            return $user;
        });

        $token = $user->createToken('auth_token')->plainTextToken;
        $customer = $user->customer;

        return response()->json([
            'status' => 'success',
            'data'   => [
                'token'          => $token,
                'name'           => $validated['name'],
                'type'           => $user->type,
                'points_balance' => $customer ? ($customer->points_balance ?? 0) : 0,
            ]
        ], 201);
    }

    /**
     * تسجيل دخول الزبون
     */
    public function login(Request $request)
    {
        $validated = $request->validate([
            'phone'     => ['required', 'digits:10'],
            'password'  => ['required', 'string'],
            'fcm_token' => ['nullable', 'string'],
        ]);

        $customer = Customer::where('phone', $validated['phone'])->first();

        if (!$customer || !$customer->user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'رقم الهاتف أو كلمة المرور غير صحيحة.'
            ], 401);
        }

        $user = $customer->user;

        if (!Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'رقم الهاتف أو كلمة المرور غير صحيحة.'
            ], 401);
        }

        if ($request->fcm_token) {
            $customer->update(['fcm_token' => $request->fcm_token]);
        }

        if ($user->type === 'customer' && $user->customer) {
            try {
                $this->pointsService->earnPointsForLogin($user->customer->id);
                $customer->refresh();
            } catch (\Throwable $e) {
                Log::error('Points Service Login Error: ' . $e->getMessage());
            }
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'data'   => [
                'token'          => $token,
                'name'           => $customer->name,
                'type'           => $user->type,
                'points_balance' => $customer->points_balance ?? 0,
            ]
        ], 200);
    }

    /**
     * تسجيل دخول الإدمن
     */
    public function adminLogin(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['status' => 'error', 'message' => 'بيانات الاعتماد غير صحيحة'], 401);
        }

        if ($user->type !== 'admin') {
            return response()->json(['status' => 'error', 'message' => 'غير مخول بالوصول'], 403);
        }

        $token = $user->createToken('admin_token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'token'   => $token,
            'user'    => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
            ]
        ]);
    }

    /**
     * تسجيل الخروج
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['status' => 'success', 'message' => 'تم تسجيل الخروج بنجاح']);
    }

    /**
     * تغيير كلمة المرور
     */
    public function changePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password'         => ['required', 'confirmed', 'min:8'],
        ]);

        $user = $request->user();
        $user->update(['password' => Hash::make($validated['password'])]);
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        try {
            Notification::send(
                $user->customer->id,
                'security_alert',
                'تنبيه أمني: تغيير كلمة المرور 🔐',
                'تم تحديث كلمة المرور الخاصة بحسابك بنجاح.',
                ['icon' => 'security_shield', 'target_screen' => 'profile_settings']
            );
        } catch (\Throwable $e) {
            Log::error('Notification Error: ' . $e->getMessage());
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم تغيير كلمة السر بنجاح',
            'data'    => ['token' => $token, 'token_type' => 'Bearer']
        ]);
    }
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email'     => ['required', 'email', 'exists:users,email'],
            'otp_code'  => ['required', 'string'],
            'password'  => ['required', 'confirmed', 'min:8'],
        ], [
            'email.required'     => 'يرجى إدخال البريد الإلكتروني.',
            'email.email'        => 'صيغة البريد الإلكتروني غير صحيحة.',
            'email.exists'       => 'البريد الإلكتروني هذا غير مسجل لدينا.',
            'otp_code.required'  => 'رمز التحقق (OTP) مطلوب.',
            'password.required'  => 'يرجى إدخال كلمة المرور الجديدة.',
            'password.confirmed' => 'تأكيد كلمة المرور غير مطابق.',
            'password.min'       => 'يجب أن لا تقل كلمة المرور عن 8 خانات.',
        ]);
        // تنظيف الإيميل
        $email = strtolower(trim($request->email));

        // البحث عن المستخدم
        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'البريد الإلكتروني غير مسجل لدينا.'
            ], 422);
        }

        // التحقق من OTP
        if (!OTPController::verifyOtp($email, $request->otp_code)) {
            return response()->json([
                'status' => 'error',
                'message' => 'رمز التحقق (OTP) غير صحيح أو منتهي الصلاحية.'
            ], 422);
        }

        // تغيير كلمة المرور
        $user->update([
            'password' => Hash::make($request->password),
        ]);

        // حذف التوكنات القديمة
        $user->tokens()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم إعادة تعيين كلمة المرور بنجاح، يمكنك الآن تسجيل الدخول.'
        ], 200);
    }
    /**
     * حذف الحساب وتجهيل البيانات
     */
    public function deleteAccount(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'المستخدم غير موجود أو غير مسجل الدخول.'
            ], 401);
        }
        $request->validate([
            'phone' => ['required', 'digits:10']
        ]);
        $customer = $user->customer;
        if (!$customer || $customer->phone !== $request->phone) {
            return response()->json([
                'status'  => 'error',
                'message' => 'رقم الهاتف المدخل غير مطابِق لرقم الحساب المرتبط'
            ], 422);
        }
        try {
            DB::transaction(function () use ($user) {
                $user->tokens()->delete();

                $customer = $user->customer;
                if ($customer) {
                    DB::table('carts')->where('customer_id', $customer->id)->delete();

                    $customer->update([
                        'name'      => 'حساب محذوف',
                        'phone'     => 'deleted_' . $customer->id . '_' . time(),
                        'fcm_token' => null,
                        'avatar'    => null,
                    ]);
                }

                $user->update([
                    'name'     => 'Anonymized User',
                    'email'    => 'deleted_' . $user->id . '@deleted.com',
                    'password' => bcrypt(\Illuminate\Support\Str::random(32)),
                ]);

                $user->delete();
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'تم حذف الحساب وتجهيل البيانات بنجاح.'
            ], 200);
        } catch (\Throwable $e) {
            Log::error('Anonymize Account Error: ' . $e->getMessage());

            return response()->json([
                'status'  => 'error',
                'message' => 'حدث خطأ أثناء حذف الحساب: ' . $e->getMessage()
            ], 500);
        }
    }
}
