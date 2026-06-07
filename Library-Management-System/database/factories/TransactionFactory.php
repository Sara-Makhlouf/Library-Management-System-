<?php

namespace Database\Factories;

use App\Models\Bill;
use App\Models\Book;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

class TransactionFactory extends Factory
{
    protected $model = Transaction::class;

    public function definition(): array
    {
        $type      = fake()->randomElement(['buy', 'borrow']);
        $createdAt = fake()->dateTimeBetween('-3 months', 'now');
        $createdAtCarbon = Carbon::instance($createdAt);

        if ($type === 'buy') {
            $status     = 'sold';
            $dueDate    = null;
            $returnedAt = null;
        } else {
            $status = fake()->randomElement(['received', 'returned', 'expired']);
            $dueDate = $createdAtCarbon->copy()->addDays(7);

            $returnedAt = ($status === 'returned')
                ? $createdAtCarbon->copy()->addDays(rand(1, 10))
                : null;
        }

        $book  = Book::inRandomOrder()->first();
        $price = ($type === 'buy') ? ($book->sale_price ?? 15000) : ($book->price ?? 5000);

        $extraPrice = ($status === 'expired')
            ? round($price * 0.03 * rand(1, 10), 2)
            : 0;

        return [
            'bill_id'      => Bill::inRandomOrder()->first()?->id ?? Bill::factory(),
            'book_id'      => $book?->id ?? Book::factory(),
            'user_id'      => User::where('type', 'customer')->inRandomOrder()->first()?->id
                ?? User::factory()->create(['type' => 'customer'])->id,
            'price'        => $price,
            'extra_price'  => $extraPrice,
            'type'         => $type,
            'status'       => $status,
            'delivered_at' => $createdAt,
            'due_date'     => $dueDate,
            'returned_at'  => $returnedAt,
            'created_at'   => $createdAt,
            'updated_at'   => $createdAt,
        ];
    }
}
