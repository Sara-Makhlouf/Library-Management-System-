<?php

namespace App\Http\Controllers; // توحيد الـ namespace مع بقية المشروع ✅

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    /**
     * عرض جميع الإعدادات
     */
    public function index()
    {
        $settings = Setting::all();

        return response()->json([
            'status' => 'success',
            'message' => 'جميع الإعدادات',
            'data' => $settings
        ]);
    }

    /**
     * تحديث إعداد معين عبر اسمه (name)
     */
    public function update(Request $request)
    {
        $request->validate([
            'name'  => ['required', 'exists:settings,name'],
            'value' => ['required', 'string'],
        ]);

        // تحديث القيمة بناءً على اسم الإعداد
        Setting::where('name', $request->name)
            ->update(['value' => $request->value]);

        $settings = Setting::all();

        return response()->json([
            'status' => 'success',
            'message' => 'تم تعديل الإعدادات بنجاح',
            'data' => $settings
        ]);
    }

    /**
     * إعدادات الـ Footer
     */
    public function footer()
    {
        $keys = [
            'site_name',
            'site_description',
            'contact_phone',
            'contact_email',
            'facebook_url',
            'instagram_url',
            'footer_copyright',
        ];

        $settings = Setting::whereIn('name', $keys)
            ->pluck('value', 'name');

        return response()->json([
            'status' => 'success',
            'message' => 'إعدادات الـ Footer',
            'data' => $settings
        ]);
    }
}
