<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ContestParticipant extends Model
{
    protected $fillable = [
        'contest_id',
        'customer_id',
        'current_progress',
        'status'
    ];
    public function contest()
    {
        return $this->belongsTo(Contest::class);
    }
    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
