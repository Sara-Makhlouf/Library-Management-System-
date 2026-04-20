<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Enums\BookStockOperationType;

class BookStockOperation extends Model
{

    protected $fillable = [
        'quantity',
        'type',
        'remove_from_remaining',
        'book_id',
    ];

    protected $casts = [
        'type' => BookStockOperationType::class,
        'remove_from_remaining' => 'boolean',
    ];

    public function book()
    {
        return $this->belongsTo(Book::class);
    }
}
