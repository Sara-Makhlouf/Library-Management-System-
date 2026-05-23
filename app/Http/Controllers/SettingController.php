<?php

namespace App\Http\Controllers;

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

        return apiSuccess('جميع الإعدادات', $settings);
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

        Setting::where('name', $request->name)
            ->update(['value' => $request->value]);

        $settings = Setting::all();

        return apiSuccess('تم تعديل الإعدادات بنجاح', $settings);
    }

    /**
     * إعدادات الـ Footer
     *
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

        return apiSuccess('إعدادات الـ Footer', $settings);
    }
}
