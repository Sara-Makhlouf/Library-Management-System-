<?php

namespace App\Traits;

use App\Models\Translation;
use Illuminate\Database\Eloquent\Model; // مهم جداً
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Support\Facades\App;

/**
 * @method static void observe($class)
 * @method static void retrieved(callable $callback)
 * @method \Illuminate\Database\Eloquent\Relations\MorphMany morphMany(string $related, string $name, string $type = null, string $id = null, string $localKey = null)
 * @mixin Model
 */
trait Translatable
{
    public static function bootTranslatable(): void
    {

        static::observe(\App\Observers\TranslationObserver::class);

        static::retrieved(function ($model) {
            if (property_exists($model, 'translatable') && is_array($model->translatable)) {
                $model->load('translations');
            }
        });
    }

    public function getAttribute($key)
    {

        if (
            property_exists($this, 'translatable') &&
            is_array($this->translatable) &&
            in_array($key, $this->translatable)
        ) {

            $locale = App::getLocale();
            $translation = $this->translations()->where('key', $key)->where('locale', $locale)->first();

            if ($translation) {
                return $translation->value;
            }
        }

        return parent::getAttribute($key);
    }

    public function getTranslation(string $key, ?string $locale = null)
    {
        $locale = $locale ?: App::getLocale();


        $translation = $this->translations()
            ->where('key', $key)
            ->where('locale', $locale)
            ->first();

        return $translation ? $translation->value : null;
    }

    public function translations(): MorphMany
    {
        return $this->morphMany(Translation::class, 'translatable');
    }

    public function toArray()
    {
        $data = parent::toArray();

        if (App::getLocale() !== 'ar' && property_exists($this, 'translatable') && is_array($this->translatable)) {
            foreach ($this->translatable as $field) {
                $translation = $this->getTranslation($field, App::getLocale());
                if ($translation) {
                    $data[$field] = $translation;
                }
            }
        }

        return $data;
    }
}
