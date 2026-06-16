<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use Translatable;

    public $timestamps = false;
    protected $fillable = ['name'];

    public array $translatable = ['name'];

    function books()
    {
        return $this->hasMany(Book::class);
    }
}
