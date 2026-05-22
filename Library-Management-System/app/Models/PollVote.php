<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PollVote extends Model
{
    protected $fillable = [
        'poll_option_id',
        'customer_id'
    ];
    public function option()
    {
        return $this->belongsTo(PollOption::class);
    }
    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
