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

        // رقم عشوائي لمنع المتصفح من تخزين (Cache) نفس الصورة لجميع الكتب
        $sig = fake()->numberBetween(1, 10000);

        return [
            'ISBN'            => fake()->unique()->numerify('9###########'),
            'title'           => fake()->realTextBetween(10, 60),
            'price'           => $borrowPrice,
            'sale_price'      => $salePrice,
            // رابط يجلب صور أغلفة كتب ومكتبات حقيقية وعالية الجودة
            // خيار آخر داخل definition() لو أردتِ تنزيل صور حقيقية محلياً:
            'cover' => function () {
                $imageUrl = 'https://picsum.photos/400/600'; // أو رابط Unsplash
                $imageContent = @file_get_contents($imageUrl);

                if ($imageContent) {
                    $filename = 'covers/' . \Illuminate\Support\Str::random(10) . '.jpg';
                    \Illuminate\Support\Facades\Storage::disk('public')->put($filename, $imageContent);
                    return $filename;
                }

                return 'covers/default.png'; // Fallback في حال عدم توفر اتصال بالإنترنت
            },
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
