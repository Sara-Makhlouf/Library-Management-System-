<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'password' => ['required', 'confirmed', 'min:8'],
            'name'     => ['required', 'string', 'max:255'],
            'gender'   => ['required', 'in:M,F'],
            'phone'    => ['required', 'digits:10', 'unique:customers,phone'],
            'DOB'      => ['required', 'date', 'before:today'],
            'lang'     => ['sometimes', 'in:ar,en'],
            'type'     => ['sometimes', 'in:admin,customer'],
            'avatar'   => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('customer-avatars', 'public');
        }

        $user = DB::transaction(function () use ($validated, $avatarPath) {
            $user = User::create([
                'email'    => $validated['phone'] . '@library.local',
                'password' => $validated['password'],
                'type'     => $validated['type'] ?? 'customer',
            ]);

            $user->customer()->create([
                'name'   => $validated['name'],
                'gender' => $validated['gender'],
                'phone'  => $validated['phone'],
                'DOB'    => $validated['DOB'],
                'lang'   => $validated['lang'] ?? 'ar',
                'avatar' => $avatarPath,
            ]);

            Notification::send(
                $user->id,
                'welcome_notification',
                'أهلاً بك في عائلتنا! 🎉',
                'تم إنشاء حسابك بنجاح. استمتع برحلتك الثقافية واستكشف آلاف الكتب المتاحة لك.',
                [
                    'icon' => 'welcome_user',
                    'target_screen' => 'home_dashboard'
                ]
            );

            return $user;
    }); 

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الحساب بنجاح',
            'data' => [
                'token'      => $token,
                'token_type' => 'Bearer',
                'type'       => $user->type,
            ]
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone'    => ['required', 'digits:10'],
            'password' => ['required'],
        ]);

        $customer = Customer::where('phone', $request->phone)->first();

        if (! $customer) {
            throw ValidationException::withMessages([
                'phone' => 'رقم الهاتف غير مسجل',
            ]);
        }

        if (! Auth::attempt(['email' => $customer->user->email, 'password' => $request->password])) {
            throw ValidationException::withMessages([
                'password' => 'كلمة المرور غير صحيحة',
            ]);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الدخول بنجاح',
            'data' => [
                'token'      => $token,
                'token_type' => 'Bearer',
                'type'       => $user->type,
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تسجيل الخروج بنجاح'
        ]);
    }

    public function changePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password'         => ['required', 'confirmed', 'min:8'],
        ]);

        /** @var \App\Models\User $user */
        $user = $request->user();

        $user->update(['password' => $validated['password']]);

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        try {
            Notification::send(
                $user->id,
                'security_alert',
                'تنبيه أمني: تغيير كلمة المرور 🔐',
                'نود إحاطتك بأنه قد تم تحديث كلمة المرور الخاصة بحسابك بنجاح للتو.',
                [
                    'icon' => 'security_shield',
                    'target_screen' => 'profile_settings'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز أي خطأ طارئ
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تغيير كلمة السر بنجاح',
            'data' => [
                'token'      => $token,
                'token_type' => 'Bearer',
            ]
        ]);
    }
}