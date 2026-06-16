<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Session;

class SetLocale
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $locale = Config::get('app.locale');

        if ($request->has('locale')) {
            $locale = $request->input('locale');
            Session::put('locale', $locale);
        } elseif (Session::has('locale')) {
            $locale = Session::get('locale');
        } elseif ($request->hasHeader('Accept-Language')) {
            $locale = substr($request->header('Accept-Language'), 0, 2);
        }

        $supportedLocales = ['en', 'ar'];
        if (!in_array($locale, $supportedLocales)) {
            $locale = Config::get('app.fallback_locale', 'en');
        }

        App::setLocale($locale);

        return $next($request);
    }
}
