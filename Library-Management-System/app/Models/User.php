<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

   protected $fillable = [
    'name', 'email', 'password', 'phone', 'image', 'birth_date', 'points', 'role'
];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

public function borrows() {
    return $this->hasMany(Order::class);
}

public function reviews() {
    return $this->hasMany(Review::class);
}

public function bookRequests() {
    return $this->hasMany(BookRequest::class);
}

}

