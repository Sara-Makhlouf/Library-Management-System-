<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'bill_id',
        'book_id',
        'price',
        'extra_price',
        'delivered_at',
        'due_date',
        'returned_at',
        'customer_return_amount', 
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

    
    public function bill(): BelongsTo
    {
        return $this->belongsTo(Bill::class);
    }

   
    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
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