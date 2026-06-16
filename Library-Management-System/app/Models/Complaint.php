<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Complaint extends Model
{
    use HasFactory;
    use Translatable;

    protected $fillable = [
        'transaction_id',
        'user_id',
        'reason',
        'total_fine',
        'status'
    ];
    public array $translatable = ['reason'];

    protected $casts = [
        'total_fine' => 'decimal:2',
    ];


    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
