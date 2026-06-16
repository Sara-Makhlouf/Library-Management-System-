<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Support\Facades\Log;

class Notification extends Model
{
    use Translatable;
    // 1. ثوابت أنواع الإشعارات الشاملة لتغطية كل أحداث التطبيق
    public const TYPE_BOOK_AVAILABLE   = 'book_available';
    public const TYPE_OVERDUE_RETURN   = 'overdue_return';
    public const TYPE_POINTS_EARNED    = 'points_earned';
    public const TYPE_POINTS_DEDUCTED  = 'points_deducted';
    public const TYPE_PURCHASE_SUCCESS = 'purchase_success';
    public const TYPE_ACCOUNT_STATUS   = 'account_status';

    public $timestamps = false;


    protected $fillable = [
        'customer_id',
        'type',
        'title',
        'body',
        'data',
        'related_id',
        'related_type',
        'is_read',
        'sent_at',
        'created_at',
    ];


    protected $casts = [
        'is_read'    => 'boolean',
        'data'       => 'array',
        'sent_at'    => 'datetime',
        'created_at' => 'datetime',
    ];
    public array $translatable = ['title', 'body'];

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function related(): MorphTo
    {
        return $this->morphTo();
    }

    // Scopes لجلب الإشعارات غير المقروءة أو التصفية حسب العميل
    public function scopeUnread(Builder $query): Builder
    {
        return $query->where('is_read', false);
    }

    public function scopeForCustomer(Builder $query, int $customerId): Builder
    {
        return $query->where('customer_id', $customerId);
    }
    public static function send(
        int $customerId,
        string $type,
        string $title,
        string $body,
        ?array $data = null,
        ?Model $relatedModel = null
    ): self {
        $notification = self::create([
            'customer_id'  => $customerId,
            'type'         => $type,
            'title'        => $title,
            'body'         => $body,
            'data'         => $data,
            'related_id'   => $relatedModel ? $relatedModel->getKey() : null,
            'related_type' => $relatedModel ? $relatedModel->getMorphClass() : null,
            'sent_at'      => now(),
            'created_at'   => now(),
        ]);

        try {
            $customer = \App\Models\Customer::find($customerId);

            if ($customer && $customer->fcm_token) {
                app(\App\Services\FCMService::class)->sendToDevice(
                    $customer->fcm_token,
                    $title,
                    $body,
                    [
                        'type'            => $type,
                        'notification_id' => (string) $notification->id,
                        'target_screen'   => $data['target_screen'] ?? 'home',
                    ]
                );
            }
        } catch (\Exception $e) {
            Log::error('Push Notification Failed: ' . $e->getMessage());
        }

        return $notification;
    }
}
