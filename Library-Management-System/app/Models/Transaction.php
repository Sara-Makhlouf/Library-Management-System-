<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

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
        'status'

    ];

    protected $casts = [
        'delivered_at' => 'datetime',
        'due_date' => 'datetime',
        'returned_at' => 'datetime',
        'price' => 'decimal:2',
        'mortgage' => 'decimal:2',

        'extra_price' => 'decimal:2',
        'customer_return_amount' => 'decimal:2'


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
        return $this->hasOneThrough(User::class, 'id', 'id', 'bill_id', 'user_id');
    }
}
