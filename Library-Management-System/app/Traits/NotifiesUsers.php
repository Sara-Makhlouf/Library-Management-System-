<?php

namespace App\Traits;

use App\Models\Notification;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

trait NotifiesUsers
{
    protected function notifySafe(
        int $customerId,
        string $type,
        string $title,
        string $body,
        ?array $data = null,
        ?Model $relatedModel = null
    ): void {
        try {
            Notification::send($customerId, $type, $title, $body, $data, $relatedModel);
        } catch (\Exception $e) {
            Log::warning("Notification failed [{$type}]: " . $e->getMessage());
        }
    }
}
