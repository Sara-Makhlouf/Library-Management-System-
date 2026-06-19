<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserReadingProgress extends Model
{
    use HasFactory;


    protected $table = 'user_reading_progress';

    protected $fillable = [
        'customer_id',
        'book_id',
        'last_page_read'
    ];

    /**
     * العلاقة مع العميل
     */
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    /**
     * العلاقة مع الكتاب
     */
    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }


    public function getPercentageAttribute()
    {
        if ($this->book && $this->book->total_pages > 0)
            return ($this->last_page_read / $this->book->total_pages) * 100;
        return 0;
    }
}
