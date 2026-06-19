<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WaitingList extends Model
{
    use HasFactory;

    protected $fillable = ['customer_id', 'book_id'];

    // العلاقة مع الزبون
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    // العلاقة مع الكتاب
    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }
}
