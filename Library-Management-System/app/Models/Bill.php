<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Bill extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'total_price',
        'discount_amount',
        'status',
        'payment_method',
        'is_delivery',
        'delivery_address',
        'delivery_status',
        'delivery_fee',
    ];


    protected $casts = [
        'total_price' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'delivery_fee' => 'decimal:2',
    ];

    /*
     * ربط الفاتورة بالعميل
     */
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }


    public function details(): HasMany
    {
        return $this->hasMany(BillDetail::class);
    }


    public function books(): BelongsToMany
    {
        return $this->belongsToMany(Book::class, 'bill_details')
            ->withPivot('quantity', 'unit_price') // لجلب بيانات الجدول الوسيط
            ->withTimestamps();
    }
}
