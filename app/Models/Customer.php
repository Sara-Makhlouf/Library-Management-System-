<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Customer extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'gender',
        'DOB',
        'phone',
        'avatar',
        'lang',
        'user_id',
        'points_balance',
    ];

    protected $casts = [
        'DOB'            => 'date',
        'points_balance' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function cart(): HasOne
    {
        return $this->hasOne(Cart::class);
    }

    public function ratings()
    {
        return $this->belongsToMany(Book::class, 'ratings')
            ->withPivot('rate')
            ->withTimestamps();
    }
}
