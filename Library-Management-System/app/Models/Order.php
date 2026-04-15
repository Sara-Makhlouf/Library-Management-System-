<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'book_id',
        'type',
        'borrow_date',
        'due_date',
        'return_date',
        'status',
        'insurance_paid',
        'penalty_amount',
        'total_price',
        'payment_method'
    ];

    protected $casts = [
        'borrow_date' => 'date',
        'due_date' => 'date',
        'return_date' => 'date',
        'insurance_paid' => 'decimal:2',
        'penalty_amount' => 'decimal:2',
        'total_price' => 'decimal:2',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function book() {
        return $this->belongsTo(Book::class);
    }

    public function delivery() {
        return $this->hasOne(Delivery::class);
    }

    public function isSale() {
        return $this->type === 'sale';
    }
}
