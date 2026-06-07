<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{

    protected $fillable = ['book_id', 'customer_id', 'rate'];

    protected $primaryKey = ['book_id', 'customer_id'];
    public $incrementing = false;

    protected function setKeysForSaveQuery($query)
    {
        $query->where('book_id', $this->getAttribute('book_id'))
            ->where('customer_id', $this->getAttribute('customer_id'));
        return $query;
    }

    public function book()
    {
        return $this->belongsTo(Book::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
