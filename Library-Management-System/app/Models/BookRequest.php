<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class BookRequest extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'book_title',
        'author_name',
        'status',
        'is_notified',
        'admin_notes'
    ];

    protected $casts = [
        'is_notified' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
