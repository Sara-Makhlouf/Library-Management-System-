<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use Translatable;
    protected $fillable = [
        'name',
        'value',
    ];
    public array $translatable = ['value'];
}
