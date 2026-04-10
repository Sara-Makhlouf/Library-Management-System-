<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Delivery extends Model
{
    protected $fillable = ['order_id', 'delivery_man_id', 'address', 'phone_number', 'status', 'notes'];

    public function order() {
        return $this->belongsTo(Order::class);
    }

    public function deliveryMan() {
        return $this->belongsTo(User::class, 'delivery_man_id');
    }

}
