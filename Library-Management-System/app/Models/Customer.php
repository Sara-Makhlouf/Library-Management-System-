<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    /** @use HasFactory<\Database\Factories\CustomerFactory> */
    use HasFactory;

    protected $fillable = [
        'name',
        'gender',
        'DOB',
        'phone',
        'avatar',
        'lang',
        'address',
        'user_id',
        'points_balance'
    ];

    protected $casts = [
        'DOB' => 'date',
        'points_balance' => 'integer',
    ];



    /**
     * العلاقة مع حساب المستخدم الأساسي (Auth).
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * علاقة الكتب المفضلة (Favorites).
     *
     */
    public function favorites(): BelongsToMany
    {
        return $this->belongsToMany(Book::class, 'favorites')
                    ->withTimestamps();
    }

    /**
     * العلاقة مع تقييمات الكتب.
     */
    public function ratings(): BelongsToMany
    {
        return $this->belongsToMany(Book::class, 'ratings')
                    ->withPivot('rate')
                    ->withTimestamps();
    }

    /**
     * العلاقة مع الإشعارات.
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * العلاقة مع قائمة الانتظار.
     */
    public function waitingLists(): HasMany
    {
        return $this->hasMany(WaitingList::class);
    }
    // app/Models/Customer.php

public function bills() {
    return $this->hasMany(Bill::class);
}

// علاقة غير مباشرة للوصول للكتب المشتراة
public function purchasedItems() {
    return $this->hasManyThrough(BillDetail::class, Bill::class);
}

public function transactions() {
    return $this->hasManyThrough(Transaction::class, Bill::class);
}
}
