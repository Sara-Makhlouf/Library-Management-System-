<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'bill_id',
        'book_id',
        'price',
        'extra_price',
        'delivered_at',
        'due_date',
        'returned_at',
        'status',
        'type'
    ];

    protected $casts = [
        'delivered_at' => 'datetime',
        'due_date' => 'datetime',
        'returned_at' => 'datetime',
        'price' => 'decimal:2',
        'extra_price' => 'decimal:2'
    ];

    public function book()
    {
        return $this->belongsTo(Book::class);
    }

    public function bill()
    {
        return $this->belongsTo(Bill::class);
    }

    public function user()
    {
        return $this->hasOneThrough(
            User::class,
            Bill::class,
            'id',
            'id',
            'bill_id',
            'user_id'
        );
    }
}