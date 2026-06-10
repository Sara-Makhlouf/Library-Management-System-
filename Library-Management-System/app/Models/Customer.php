<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

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
        'address',
        'user_id',
        'fcm_token',
    ];

    protected $casts = [
        'DOB' => 'date',
        'points_balance' => 'integer',
        'max_borrowing_limit' => 'integer',
    ];



    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * علاقة الكتب المفضلة.
     */
    public function favorites()
    {
        return $this->belongsToMany(Book::class, 'favorites', 'customer_id', 'book_id')->withTimestamps();
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
     * العلاقة مع الفواتير.
     */
    public function bills(): HasMany
    {
        return $this->hasMany(Bill::class);
    }

    /**
     * الوصول للعمليات (استعارة/بيع) المرتبطة بفواتير هذا الزبون.
     */
    public function transactions(): HasManyThrough
    {
        return $this->hasManyThrough(Transaction::class, Bill::class);
    }

    /**
     * العلاقة مع قائمة الانتظار.
     */
    public function waitingLists(): HasMany
    {
        return $this->hasMany(WaitingList::class);
    }

    /**
     * العلاقة مع الإشعارات.
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }
}
