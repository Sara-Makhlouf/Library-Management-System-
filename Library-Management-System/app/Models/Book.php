<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Book extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'title',
        'author_name',
        'description',
        'cover_image',
        'borrow_price',
        'insurance_fee',
        'stock_count',
        'pdf_path',
        'is_digital',
        'is_available'
    ];

    protected $casts = [
        'is_digital' => 'boolean',
        'is_available' => 'boolean',
        'borrow_price' => 'decimal:2',
        'insurance_fee' => 'decimal:2',
    ];

    public function isForSale() {
    return $this->allow_sale && $this->sale_price > 0;
}
    public function category() {
        return $this->belongsTo(Category::class);
    }

    public function borrows() {
        return $this->hasMany(Order::class);
    }

    public function reviews() {
        return $this->hasMany(Review::class);
    }
}
