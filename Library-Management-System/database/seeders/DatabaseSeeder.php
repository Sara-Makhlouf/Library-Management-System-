<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Author;
use App\Models\Book;
use App\Models\Customer;
use App\Models\Bill;
use App\Models\BillDetail;
use App\Models\Transaction;
use App\Models\Setting;
use App\Models\Rating;
use App\Models\Cart;
use App\Models\WaitingList;
use App\Models\BookRequest;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {

        $this->call([AdminSeeder::class]);

        $categoryNames = ['روايات', 'تكنولوجيا', 'تاريخ', 'علوم', 'فن وأدب', 'فلسفة', 'اقتصاد'];
        foreach ($categoryNames as $name) {
            Category::create(['name' => $name]);
        }

        $authors = Author::factory(10)->create();

        $allBooks = Book::factory(30)->create();

        $allBooks->each(function ($book) use ($authors) {
            $book->authors()->attach(
                $authors->random(rand(1, 2))->pluck('id')->toArray()
            );
        });

        $customers = Customer::factory(10)->create();

        foreach ($customers as $customer) {

            $bill = Bill::create([
                'customer_id'    => $customer->id,
                'total_price'    => 0,
                'discount_amount' => 0,
                'status'         => 'paid',
                'payment_method' => fake()->randomElement(['cash', 'online']),
                'is_delivery'    => false,
                'delivery_fee'   => 0,
            ]);

            $totalBillPrice = 0;

            $selectedBooks = $allBooks->random(3);

            foreach ($selectedBooks as $index => $book) {
                $type  = ($index === 0) ? 'buy' : 'borrow';
                $price = ($type === 'buy') ? $book->sale_price : $book->price;

                $dueDate   = ($type === 'borrow') ? Carbon::now()->addDays(7) : null;
                $status    = ($type === 'buy') ? 'sold' : 'returned';
                $returnedAt = ($type === 'borrow') ? Carbon::now()->subDays(rand(1, 5)) : null;

                Transaction::create([
                    'bill_id'      => $bill->id,
                    'book_id'      => $book->id,
                    'user_id'      => $customer->user_id,
                    'type'         => $type,
                    'price'        => $price,
                    'extra_price'  => 0,
                    'status'       => $status,
                    'delivered_at' => now(),
                    'due_date'     => $dueDate,
                    'returned_at'  => $returnedAt,
                ]);

                BillDetail::create([
                    'bill_id'    => $bill->id,
                    'book_id'    => $book->id,
                    'quantity'   => 1,
                    'unit_price' => $price,
                ]);

                $totalBillPrice += $price;

                $alreadyRated = Rating::where('book_id', $book->id)
                    ->where('customer_id', $customer->id)
                    ->exists();

                if (!$alreadyRated) {
                    Rating::create([
                        'book_id'     => $book->id,
                        'customer_id' => $customer->id,
                        'rate'        => rand(3, 5),
                    ]);
                }
            }

            $bill->update(['total_price' => $totalBillPrice]);

            $cart = Cart::create([
                'customer_id' => $customer->id,
                'total_price' => 0,
            ]);

            $cartBooks   = $allBooks->whereNotIn('id', $selectedBooks->pluck('id'))->random(2);
            $cartTotal   = 0;

            foreach ($cartBooks as $cartBook) {
                $type  = fake()->randomElement(['buy', 'borrow']);
                $price = ($type === 'buy') ? $cartBook->sale_price : $cartBook->price;

                $alreadyInCart = DB::table('cart_details')
                    ->where('cart_id', $cart->id)
                    ->where('book_id', $cartBook->id)
                    ->exists();

                if (!$alreadyInCart) {
                    DB::table('cart_details')->insert([
                        'cart_id'    => $cart->id,
                        'book_id'    => $cartBook->id,
                        'price'      => $price,
                        'type'       => $type,
                        'due_at'     => ($type === 'borrow') ? now()->addDays(7) : null,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    $cartTotal += $price;
                }
            }

            $cart->update(['total_price' => $cartTotal]);

            $favoriteBooks = $allBooks->random(rand(2, 4))->pluck('id')->unique()->toArray();
            foreach ($favoriteBooks as $bookId) {
                $alreadyFav = DB::table('favorites')
                    ->where('customer_id', $customer->id)
                    ->where('book_id', $bookId)
                    ->exists();

                if (!$alreadyFav) {
                    DB::table('favorites')->insert([
                        'customer_id' => $customer->id,
                        'book_id'     => $bookId,
                        'created_at'  => now(),
                        'updated_at'  => now(),
                    ]);
                }
            }

            $waitingBook = $allBooks->whereNotIn('id', $selectedBooks->pluck('id'))->random();
            $alreadyWaiting = WaitingList::where('customer_id', $customer->id)
                ->where('book_id', $waitingBook->id)
                ->exists();

            if (!$alreadyWaiting) {
                WaitingList::create([
                    'customer_id' => $customer->id,
                    'book_id'     => $waitingBook->id,
                ]);
            }

            BookRequest::create([
                'customer_id' => $customer->id,
                'book_title'  => fake()->sentence(3),
                'author_name' => fake()->name(),
                'notes'       => fake()->sentence(5),
                'status'      => fake()->randomElement(['pending', 'approved', 'rejected']),
            ]);
        }

        $settings = [
            ['name' => 'site_name',        'value' => 'مكتبتي الذكية'],
            ['name' => 'footer_copyright', 'value' => 'جميع الحقوق محفوظة ٢٠٢٦'],
            ['name' => 'contact_phone',    'value' => '+963900000000'],
            ['name' => 'contact_email',    'value' => 'info@library.com'],
            ['name' => 'facebook_url',     'value' => 'https://facebook.com/library'],
            ['name' => 'instagram_url',    'value' => 'https://instagram.com/library'],
        ];

        foreach ($settings as $setting) {
            Setting::firstOrCreate(['name' => $setting['name']], ['value' => $setting['value']]);
        }
    }
}
