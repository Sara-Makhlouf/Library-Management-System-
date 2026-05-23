<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    protected $fillable = [
        'bill_id',
        'book_id',
        'price',
        'mortgage',
        'extra_price',
        'delivered_at',
        'due_date',
        'returned_at',
        'customer_return_amount',
        'status',
    ];

    protected $casts = [
        'price'                 => 'decimal:2',
        'mortgage'              => 'decimal:2',
        'extra_price'           => 'decimal:2',
        'customer_return_amount'=> 'decimal:2',
        'delivered_at'          => 'datetime',
        'due_date'              => 'datetime',
        'returned_at'           => 'datetime',
    ];

    public function bill(): BelongsTo
    {
        return $this->belongsTo(Bill::class);
    }

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }
}
