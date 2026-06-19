<?php

namespace App\Models;

use App\Traits\Translatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Book extends Model
{
    /** @use HasFactory<\Database\Factories\BookFactory> */
    use HasFactory, SoftDeletes;
    use Translatable;
    protected $fillable = [
        'ISBN',
        'title',
        'price',
        'sale_price',
        'cover',
        'borrow_duration',
        'total_copies',
        'stock',
        'authorship_date',
        'category_id',
        'file_path',
        'is_digital',
        'total_pages',
    ];

    protected $casts = [
        'is_digital' => 'boolean',
        'authorship_date' => 'date',
        'price' => 'decimal:2',
        'sale_price' => 'decimal:2',
    ];

    public array $translatable = ['title'];

    /**
     * التصنيف الذي ينتمي إليه الكتاب.
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * مؤلفو الكتاب.
     */
    public function authors(): BelongsToMany
    {
        return $this->belongsToMany(Author::class);
    }

    /**
     * الزبائن الذين أضافوا هذا الكتاب للمفضلة.

     */
    public function favoritedBy(): BelongsToMany
    {
        return $this->belongsToMany(Customer::class, 'favorites', 'book_id', 'customer_id')
            ->withTimestamps();
    }


    public function ratings(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Rating::class);
    }


    public function getAverageRateAttribute()
    {
        return round($this->ratings()->avg('rate') ?: 0, 1);
    }

    /**
     * سجل المعاملات (استعارة/بيع) الخاصة بهذا الكتاب.
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    /**
     * الزبائن الموجودون في قائمة الانتظار لهذا الكتاب.
     */
    public function waiters(): HasMany
    {
        return $this->hasMany(WaitingList::class);
    }
    /**
     * سجل عمليات المخزون الخاصة بهذا الكتاب.
     */
    public function stockOperations(): HasMany
    {
        return $this->hasMany(BookStockOperation::class);
    }




    // --- أدوات البحث والفلترة

    public function scopeSearch($query, array $filters = [])
    {
        return $query
            ->when(
                $filters['title'] ?? null,
                fn($q, $title) =>
                $q->where('title', 'like', "%{$title}%")
            )
            ->when(
                $filters['category_id'] ?? null,
                fn($q, $categoryId) =>
                $q->where('category_id', $categoryId)
            )
            ->when(
                $filters['author_id'] ?? null,
                fn($q, $authorId) =>
                $q->whereHas(
                    'authors',
                    fn($sub) =>
                    $sub->where('id', $authorId)
                )
            )
            ->when(
                $filters['is_digital'] ?? null,
                fn($q, $isDigital) =>
                $q->where('is_digital', $isDigital)
            );
    }
}
