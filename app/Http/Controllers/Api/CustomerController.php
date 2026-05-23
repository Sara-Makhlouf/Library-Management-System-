<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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

        return apiSuccess('بيانات العميل', [
            'name'   => $customer->name,
            'phone'  => $customer->phone,
            'gender' => $customer->gender,
            'DOB'    => $customer->DOB,
            'lang'   => $customer->lang,
            'avatar' => $customer->avatar,
            'points' => $customer->points_balance,
        ]);
    }

    /**
     * تحديث البيانات الشخصية
     * (الجنس - الهاتف - الصورة - الميلاد)
     */
    public function update(Request $request)
    {
        $customer = $request->user()->customer;

        $validated = $request->validate([
            'name'   => ['sometimes', 'string', 'max:255'],
            'gender' => ['sometimes', 'in:M,F'],
            'DOB'    => ['sometimes', 'date', 'before:today'],
            'phone'  => ['sometimes', 'digits:10', "unique:customers,phone,{$customer->id}"],
            'lang'   => ['sometimes', 'in:ar,en'],
            'avatar' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        // رفع الصورة الجديدة وحذف القديمة
        if ($request->hasFile('avatar')) {
            if ($customer->avatar) {
                Storage::delete($customer->avatar);
            }
            $validated['avatar'] = $request->file('avatar')->store('customer-avatars');
        }

        $customer->update($validated);

        return apiSuccess('تم تحديث البيانات بنجاح', [
            'name'   => $customer->name,
            'phone'  => $customer->phone,
            'gender' => $customer->gender,
            'DOB'    => $customer->DOB,
            'lang'   => $customer->lang,
            'avatar' => $customer->avatar,
        ]);
    }
}
