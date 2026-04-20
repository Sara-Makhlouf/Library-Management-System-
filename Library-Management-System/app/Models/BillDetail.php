<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BillDetail extends Model
{
    use HasFactory;


    protected $table = 'bill_details';

    protected $fillable = [
        'bill_id',
        'book_id',
        'quantity',
        'unit_price'
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
