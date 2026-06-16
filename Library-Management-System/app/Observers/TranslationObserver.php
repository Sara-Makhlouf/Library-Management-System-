<?php

namespace App\Observers;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;
use Stichoza\GoogleTranslate\GoogleTranslate;

class TranslationObserver
{
    public function saved(Model $model)
    {
        if (!property_exists($model, 'translatable') || !method_exists($model, 'translations')) {
            return;
        }

        foreach ($model->translatable as $field) {
            if ($model->isDirty($field) || ($model->wasRecentlyCreated && isset($model->{$field}))) {

                $model->translations()->updateOrCreate(
                    [
                        'key'    => $field,
                        'locale' => app()->getLocale(),
                    ],
                    [
                        'value'  => $model->{$field}
                    ]
                );
            }
        }

        if ($model->wasRecentlyCreated) {
            $this->autoTranslate($model);
        }
    }

    private function autoTranslate(Model $model)
    {
        try {
            $currentLocale = app()->getLocale();

            foreach ($model->translatable as $field) {
                if (isset($model->{$field})) {

                    if ($currentLocale === 'ar') {
                        $tr = new GoogleTranslate('en');
                        $translatedValue = $tr->translate($model->{$field});
                        $targetLocale = 'en';
                    } else {
                        $tr = new GoogleTranslate('ar');
                        $translatedValue = $tr->translate($model->{$field});
                        $targetLocale = 'ar';
                    }

                    $model->translations()->updateOrCreate(
                        [
                            'key'    => $field,
                            'locale' => $targetLocale,
                        ],
                        [
                            'value'  => $translatedValue
                        ]
                    );
                }
            }
        } catch (\Exception $e) {
            Log::error('AutoTranslation Error: ' . $e->getMessage());
        }
    }
}
