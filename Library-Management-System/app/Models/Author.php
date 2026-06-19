<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Author extends Model
{
    use HasFactory;
    use Translatable;
    public $timestamps = false;
    protected $fillable = ['name', 'birth_date', 'country'];

    public array $translatable = ['name', 'country'];

    function books()
    {
        return $this->belongsToMany(Book::class);
    }
}
