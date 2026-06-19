<?php

namespace Database\Factories;

use App\Models\Book;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

class BookFactory extends Factory
{
    protected $model = Book::class;

    public function definition(): array
    {
        $borrowPrice = fake()->randomFloat(2, 2000, 8000);
        $salePrice   = $borrowPrice * fake()->randomFloat(2, 3, 6);

        $isDigital = fake()->boolean(20);

        return [
            'ISBN'            => fake()->unique()->numerify('9###########'),
            'title'           => fake()->realTextBetween(10, 60),
            'price'           => $borrowPrice,
            'sale_price'      => $salePrice,
            'cover'           => 'covers/default.png',
            'total_pages'     => fake()->numberBetween(80, 800),
            'borrow_duration' => fake()->randomElement([7, 14, 21]),
            'total_copies'    => 10,
            'stock'           => 10,
            'authorship_date' => fake()->date('Y-m-d', '-2 years'),
            'category_id'     => Category::inRandomOrder()->first()?->id ?? Category::factory(),
            'is_digital'      => $isDigital,
            'file_path'       => $isDigital ? 'books_files/sample.pdf' : null,
        ];
    }
}
