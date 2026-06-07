<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'book_title',
        'author_name',
        'status',
        'notes',
        'admin_note',
        'customer_id',
    ];

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }


    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
}
