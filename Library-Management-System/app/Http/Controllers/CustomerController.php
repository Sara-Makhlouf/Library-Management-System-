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
     * عرض بيانات العميل الحالي
     */
    public function show(Request $request)
    {
        $customer = $request->user()->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، هذا الحساب غير مرتبط ببيانات عميل'
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'بيانات العميل',
            'data' => [
                'name'   => $customer->name,
                'phone'  => $customer->phone,
                'gender' => $customer->gender,
                'DOB'    => $customer->DOB,
                'lang'   => $customer->lang,
                'avatar' => $customer->avatar,
                'points' => $customer->points_balance,
            ]
        ]);
    }

    /**
     * تحديث البيانات الشخصية
     * (الجنس - الهاتف - الصورة - الميلاد)
     */
    public function update(Request $request)
    {
        $customer = $request->user()->customer;

        if (!$customer) {
            return response()->json([
                'status' => 'error',
                'message' => 'عذراً، لا يمكن تحديث البيانات لهذا الحساب'
            ], 403);
        }

        $validated = $request->validate([
            'name'   => ['sometimes', 'string', 'max:255'],
            'gender' => ['sometimes', 'in:M,F'],
            'DOB'    => ['sometimes', 'date', 'before:today'],
            'phone'  => ['sometimes', 'digits:10', "unique:customers,phone,{$customer->id}"],
            'lang'   => ['sometimes', 'in:ar,en'],
            'avatar' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        // رفع الصورة الجديدة وحذف القديمة من قرص الـ public بأمان
        if ($request->hasFile('avatar')) {
            if ($customer->avatar) {
                Storage::disk('public')->delete($customer->avatar);
            }
            $validated['avatar'] = $request->file('avatar')->store('customer-avatars', 'public');
        }

        $customer->update($validated);

        // 🔔 استخدام الدالة الموحدة لإرسال إشعار بتحديث الملف الشخصي بنجاح
        try {
            Notification::send(
                $request->user()->id,
                'profile_updated',
                'تم تحديث حسابك بنجاح ✨',
                'لقد قمت بتحديث بيانات ملفك الشخصي في التطبيق بنجاح لمواكبة تغييراتك الأخيرة.',
                [
                    'icon' => 'user_edit_success',
                    'target_screen' => 'profile_settings'
                ]
            );
        } catch (\Exception $e) {
            // تجاوز أي خطأ طارئ لضمان عدم توقف العملية
        }

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث البيانات بنجاح',
            'data' => [
                'name'   => $customer->name,
                'phone'  => $customer->phone,
                'gender' => $customer->gender,
                'DOB'    => $customer->DOB,
                'lang'   => $customer->lang,
                'avatar' => $customer->avatar,
            ]
        ]);
    }
}
