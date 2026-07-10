<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Contest extends Model
{
    protected $fillable = [
        'title',
        'description',
        'target_pages',
        'reward_points',
        'start_date',
        'end_date'
    ];
    public function participants()
    {
        return $this->hasMany(ContestParticipant::class);
    }
}
