<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\User;
use App\Services\PointsService;
use App\Traits\ApiResponse;
use App\Traits\NotifiesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    use ApiResponse, NotifiesUsers;

    protected $pointsService;

    public function __construct(PointsService $pointsService)
    {
        $this->pointsService = $pointsService;
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', 'min:8'],
            'gender'   => ['required', 'in:M,F'],
            'phone'    => ['required', 'digits:10', 'unique:customers,phone'],
            'DOB'      => ['required', 'date', 'before:today'],
            'lang'     => ['sometimes', 'in:ar,en'],
            'avatar'   => ['nullable', 'image', 'max:2048'],
            'fcm_token' => ['nullable', 'string'],
        ]);

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
                'name'   => $validated['name'],
                'gender' => $validated['gender'],
                'phone'  => $validated['phone'],
                'DOB'    => $validated['DOB'],
                'lang'   => $validated['lang'] ?? 'ar',
                'avatar' => $avatarPath,
                'fcm_token' => $validated['fcm_token'] ?? null,
            ]);

            if ($user->type === 'customer') {
                try {
                    $this->pointsService->addPoints($customer->id, 50, 'earn', 'هدية ترحيبية بمناسبة الانضمام للتطبيق 🎉');
                } catch (\Exception $e) {
                }
            }

            $this->notifySafe(
                $customer->id,
                'welcome_notification',
                'أهلاً بك يا ' . $validated['name'] . '! 🎉',
                'تم إنشاء حسابك بنجاح. استمتع برحلتك الثقافية معنا.',
                ['icon' => 'welcome_user', 'target_screen' => 'home_dashboard']
            );

            return $user;
        });

        $token = $user->createToken('auth_token')->plainTextToken;

        $customer = $user->customer;

        return $this->successResponse([
            'token'          => $token,
            'name'           => $validated['name'],
            'type'           => $user->type,
            'points_balance' => $customer ? ($customer->points_balance ?? 0) : 0,
        ], null, 201);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'phone'    => ['required', 'digits:10'],
            'password' => ['required', 'string'],
            'fcm_token' => ['nullable', 'string'],
        ]);

        $customer = Customer::where('phone', $validated['phone'])->first();

        if (!$customer || !$customer->user) {
            return $this->errorResponse('رقم الهاتف أو كلمة المرور غير صحيحة.', 401);
        }

        $user = $customer->user;

        if (!Hash::check($validated['password'], $user->password)) {
            return $this->errorResponse('رقم الهاتف أو كلمة المرور غير صحيحة.', 401);
        }
        if ($request->fcm_token) {
            $customer->update(['fcm_token' => $request->fcm_token]);
        }

        if ($user->type === 'customer' && $user->customer) {
            try {
                $this->pointsService->earnPointsForLogin($user->customer->id);
                $customer->refresh();
            } catch (\Exception $e) {
            }
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->successResponse([
            'token'          => $token,
            'name'           => $customer->name,
            'type'           => $user->type,
            'points_balance' => $customer->points_balance ?? 0,
        ]);
    }

    public function adminLogin(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->errorResponse('بيانات الاعتماد غير صحيحة', 401);
        }

        if ($user->type !== 'admin') {
            return $this->errorResponse('غير مخول بالوصول', 403);
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

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->successResponse(message: 'تم تسجيل الخروج بنجاح');
    }

    public function changePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password'         => ['required', 'confirmed', 'min:8'],
        ]);

        $user = $request->user();
        $user->update(['password' => $validated['password']]);

        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        $this->notifySafe(
            $user->customer->id,
            'security_alert',
            'تنبيه أمني: تغيير كلمة المرور 🔐',
            'تم تحديث كلمة المرور الخاصة بحسابك بنجاح.',
            ['icon' => 'security_shield', 'target_screen' => 'profile_settings']
        );

        return $this->successResponse([
            'token' => $token,
            'token_type' => 'Bearer'
        ], 'تم تغيير كلمة السر بنجاح');
    }
}
