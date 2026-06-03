<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cart extends Model
{
    protected $fillable = [
        
        'customer_id',
        'total_price'
    ];

    // العلاقة مع تفاصيل السلة
    public function details()
    {
        return $this->hasMany(CartDetail::class);
    }
}
