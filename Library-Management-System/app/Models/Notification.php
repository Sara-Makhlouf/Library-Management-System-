<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class Notification extends Model
{
    public const TYPE_BOOK_AVAILABLE = 'book_available';
    public const TYPE_OVERDUE_RETURN  = 'overdue_return';

   
    public const RELATED_WAITING_LIST = 'waiting_list';
    public const RELATED_TRANSACTION  = 'transaction';

    public $timestamps = false;

    protected $fillable = [
        'customer_id',
        'type',
        'title',
        'body',
        'related_id',
        'related_type',
        'is_read',
        'sent_at',
        'created_at',
    ];

    protected $casts = [
        'is_read'    => 'boolean',
        'sent_at'    => 'datetime',
        'created_at' => 'datetime',
    ];

    

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    
    public function related(): MorphTo
    {
        return $this->morphTo();
    }

   

    public function scopeUnread(Builder $query): Builder
    {
        return $query->where('is_read', false);
    }

    public function scopeForCustomer(Builder $query, int $customerId): Builder
    {
        return $query->where('customer_id', $customerId);
    }

    

    public static function sendBookAvailable(int $customerId, int $waitingListId, string $bookTitle): self
{
    return self::create([
        'customer_id'  => $customerId,
        'type'         => self::TYPE_BOOK_AVAILABLE,
        'title'        => 'الكتاب متاح الآن',
        'body'         => "الكتاب الذي طلبته «{$bookTitle}» أصبح متاحاً للاستعارة.",
        'related_id'   => $waitingListId,
        'related_type' => self::RELATED_WAITING_LIST, // نستخدم الثابت 'waiting_list'
        'sent_at'      => now(),
        'created_at'   => now(),
    ]);
}

    public static function sendOverdueReturn(int $customerId, int $transactionId, string $bookTitle): self
    {
        return self::create([
            'customer_id'  => $customerId,
            'type'         => self::TYPE_OVERDUE_RETURN,
            'title'        => 'تذكير بإعادة الكتاب',
            'body'         => "تجاوز موعد إعادة كتاب «{$bookTitle}»، يرجى إعادته في أقرب وقت.",
            'related_id'   => $transactionId,
            'related_type' => Transaction::class, // نستخدم اسم الكلاس مباشرة
            'sent_at'      => now(),
            'created_at'   => now(),
        ]);
    }
}
