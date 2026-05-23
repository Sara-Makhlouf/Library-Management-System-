<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * إنشاء حساب جديد
     * تسجيل الدخول بالهاتف وكلمة المرور
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'password' => ['required', 'confirmed', 'min:8'],
            'name'     => ['required', 'string', 'max:255'],
            'gender'   => ['required', 'in:M,F'],
            'phone'    => ['required', 'digits:10', 'unique:customers,phone'],
            'DOB'      => ['required', 'date', 'before:today'],
            'lang'     => ['sometimes', 'in:ar,en'],
            'type'     => ['sometimes', 'in:admin,customer'], // ← إذا ما حدد يكون customer تلقائياً
            'avatar'   => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        $avatarPath = null;
        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('customer-avatars');
        }

        $user = DB::transaction(function () use ($validated, $avatarPath) {
            $user = User::create([
                'email'    => $validated['phone'] . '@library.local', // email وهمي لأن تسجيل الدخول بالهاتف
                'password' => $validated['password'],
                'type'     => $validated['type'] ?? 'customer', // ← default customer
            ]);

            $user->customer()->create([
                'name'   => $validated['name'],
                'gender' => $validated['gender'],
                'phone'  => $validated['phone'],
                'DOB'    => $validated['DOB'],
                'lang'   => $validated['lang'] ?? 'ar',
                'avatar' => $avatarPath,
            ]);

            return $user;
        });

        $token = $user->createToken('auth_token')->plainTextToken;

        return apiSuccess('تم تسجيل الحساب بنجاح', [
            'token'      => $token,
            'token_type' => 'Bearer',
            'type'       => $user->type,
        ]);
    }

    /**
     * تسجيل الدخول بالهاتف وكلمة المرور
     */
    public function login(Request $request)
    {
        $request->validate([
            'phone'    => ['required', 'digits:10'],
            'password' => ['required'],
        ]);

        // البحث عن العميل بالهاتف
        $customer = Customer::where('phone', $request->phone)->first();

        if (! $customer) {
            throw ValidationException::withMessages([
                'phone' => 'رقم الهاتف غير مسجل',
            ]);
        }

        // التحقق من كلمة السر عبر الـ user المرتبط
        if (! Auth::attempt(['email' => $customer->user->email, 'password' => $request->password])) {
            throw ValidationException::withMessages([
                'password' => 'كلمة المرور غير صحيحة',
            ]);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        // حذف التوكنات القديمة وإنشاء جديد
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return apiSuccess('تم تسجيل الدخول بنجاح', [
            'token'      => $token,
            'token_type' => 'Bearer',
            'type'       => $user->type,
        ]);
    }

    /**
     * تسجيل الخروج
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return apiSuccess('تم تسجيل الخروج بنجاح');
    }

    /**
     * تغيير كلمة السر
     */
    public function changePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password'         => ['required', 'confirmed', 'min:8'],
        ]);

        /** @var \App\Models\User $user */
        $user = $request->user();

        $user->update(['password' => $validated['password']]);

        // حذف كل التوكنات وإنشاء جديد للجهاز الحالي
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return apiSuccess('تم تغيير كلمة السر بنجاح', [
            'token'      => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
