<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class CustomerController extends Controller
{
    /**
     * عرض بيانات الملف الشخصي للزبون الحالي
     */
    public function show(Request $request)
    {
        $user = $request->user();
        $customer = $user->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط ببيانات عميل'
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'name'   => $user->name,
                'email'  => $user->email,
                'phone'  => $customer->phone,
                'gender' => $customer->gender,
                'DOB'    => $customer->DOB,
                'lang'   => $customer->lang,
                'avatar' => $customer->avatar ? asset('storage/' . $customer->avatar) : null,
                'points' => $customer->points_balance,
            ]
        ]);
    }

    /**
     * تحديث البيانات الشخصية
     */
    public function update(Request $request)
    {
        $user = $request->user();
        $customer = $user->customer;

        if (!$customer) {
            return response()->json(['status' => 'error', 'message' => 'غير مسموح بالتحديث'], 403);
        }

        $validated = $request->validate([
            'name'   => ['sometimes', 'string', 'max:255'],
            'gender' => ['sometimes', 'in:M,F'],
            'DOB'    => ['sometimes', 'date', 'before:today'],
            'phone'  => ['sometimes', 'digits:10', "unique:customers,phone,{$customer->id}"],
            'lang'   => ['sometimes', 'in:ar,en'],
            'avatar' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        DB::beginTransaction();
        try {
            if ($request->has('name')) {
                $user->update(['name' => $validated['name']]);
            }

            if ($request->hasFile('avatar')) {
                if ($customer->avatar) {
                    Storage::disk('public')->delete($customer->avatar);
                }
                $validated['avatar'] = $request->file('avatar')->store('customer-avatars', 'public');
            }

            $customer->update(collect($validated)->except('name')->toArray());

            DB::commit();
            $customer->refresh();
            $user->refresh();

            // 🔔 إرسال إشعار التحديث
            try {
                Notification::send(
                    $user->customer->id,
                    'profile_updated',
                    'تم تحديث حسابك بنجاح ✨',
                    'لقد قمت بتحديث بيانات ملفك الشخصي بنجاح.',
                    ['icon' => 'user_edit_success', 'target_screen' => 'profile_settings']
                );
            } catch (\Exception $e) {
            }

            return response()->json([
                'status' => 'success',
                'message' => 'تم تحديث البيانات بنجاح',
                'data' => [
                    'name'           => $user->name,
                    'phone'          => $customer->phone,
                    'gender'         => $customer->gender,
                    'DOB'            => $customer->DOB,
                    'lang'           => $customer->lang,
                    'avatar'         => $customer->avatar ? asset('storage/' . $customer->avatar) : null,
                    'points_balance' => $customer->points_balance ?? 0,
                ]
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'status' => 'error',
                'message' => 'حدث خطأ أثناء التحديث، يرجى المحاولة لاحقاً'
            ], 500);
        }
    }
}
