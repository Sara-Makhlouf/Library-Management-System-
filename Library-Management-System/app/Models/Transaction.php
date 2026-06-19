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
        'user_id',
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

    public function bill()
    {
        return $this->belongsTo(Bill::class);
    }

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }


    public function customer()
    {
        return $this->hasOneThrough(Customer::class, User::class, 'id', 'user_id', 'user_id', 'id');
    }
}
