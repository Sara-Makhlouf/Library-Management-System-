<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PollOption extends Model
{
    protected $fillable = [
        'question',
        'option_text',
        'votes_count'
    ];
    public function votes()
    {
        return $this->hasMany(PollVote::class);
    }
}
