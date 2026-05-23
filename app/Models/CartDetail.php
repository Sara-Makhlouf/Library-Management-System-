<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartDetail extends Model
{
    protected $fillable = [
        'cart_id',
        'book_id',
        'price',
        'mortgage',
        'due_at',
    ];

    protected $casts = [
        'price'    => 'decimal:2',
        'mortgage' => 'decimal:2',
        'due_at'   => 'datetime',
    ];

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }
}
