<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookRequest extends Model
{
    use HasFactory;
    use Translatable;
    protected $fillable = [
        'book_title',
        'author_name',
        'status',
        'notes',
        'admin_note',
        'customer_id',
    ];

    public array $translatable = ['book_title', 'author_name'];
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }


    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
}
