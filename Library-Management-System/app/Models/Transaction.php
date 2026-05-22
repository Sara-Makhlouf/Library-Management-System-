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
    ];

    // علاقة العملية بالفاتورة الأم
    public function bill(): BelongsTo
    {
        return $this->belongsTo(Bill::class);
    }

    // علاقة العملية بالكتاب
    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }
}
