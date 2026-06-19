<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookStockOperation extends Model
{

    protected $fillable = [
        'quantity',
        'type',
        'remove_from_remaining',
        'book_id',
    ];

    protected $casts = [
        'type' => 'string',
        'remove_from_remaining' => 'boolean',
    ];

    public function book()
    {
        return $this->belongsTo(Book::class);
    }
}
