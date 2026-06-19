<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CartDetail extends Model
{
    protected $fillable = [
        'cart_id',
        'book_id',
        'price',
        'type',
        'due_at'
    ];

    // العلاقة مع السلة
    public function cart()
    {
        return $this->belongsTo(Cart::class);
    }


    public function book()
    {
        return $this->belongsTo(Book::class);
    }
}
