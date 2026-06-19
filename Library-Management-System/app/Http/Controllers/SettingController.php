<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Http\JsonResponse;

class SettingController extends Controller
{
    /**
     * 1 جلب كل الإعدادات
     */
    public function index(): JsonResponse
    {
        $settings = Cache::rememberForever('app_settings', function () {
            return Setting::pluck('value', 'name');
        });

        return response()->json([
            'status' => 'success',
            'data' => $settings
        ]);
    }

    /**
     * 2. تحديث الإعدادات
     */
    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'settings' => ['required', 'array'],
            'settings.*.name' => ['required', 'exists:settings,name'],
            'settings.*.value' => ['required'],
        ]);

        foreach ($request->settings as $setting) {
            Setting::where('name', $setting['name'])
                ->update(['value' => $setting['value']]);
        }

        Cache::forget('app_settings');

        return response()->json([
            'status' => 'success',
            'message' => 'تم تحديث جميع الإعدادات بنجاح',
            'data' => Setting::pluck('value', 'name')
        ]);
    }


    public function footer(): JsonResponse
    {
        $footerKeys = [
            'site_name',
            'contact_phone',
            'contact_email',
            'facebook_url',
            'instagram_url',
            'footer_copyright'
        ];

        $settings = Setting::whereIn('name', $footerKeys)->pluck('value', 'name');

        return response()->json([
            'status' => 'success',
            'data' => $settings
        ]);
    }

    /**
     * 4  دالة إضافية لجلب أي مجموعة إعدادات مخصصة
     */
    public function getByGroup(Request $request): JsonResponse
    {
        $keys = $request->input('keys', []);

        if (empty($keys)) {
            return response()->json([
                'status' => 'error',
                'message' => 'يرجى تمرير مصفوفة المفاتيح المطلوب جلبها keys'
            ], 400);
        }

        $settings = Setting::whereIn('name', (array)$keys)->pluck('value', 'name');

        return response()->json([
            'status' => 'success',
            'data' => $settings
        ]);
    }
}
