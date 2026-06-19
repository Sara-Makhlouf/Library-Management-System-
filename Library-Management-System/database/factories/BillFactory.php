<?php

namespace Database\Factories;

use App\Models\Bill;
use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\Factory;

class BillFactory extends Factory
{
    protected $model = Bill::class;

    public function definition(): array
    {
        $isDelivery = fake()->boolean(30); // 30% طلبات توصيل

        return [
            'customer_id'      => Customer::inRandomOrder()->first()?->id ?? Customer::factory(),
            'total_price'      => fake()->randomFloat(2, 5000, 50000),
            'discount_amount'  => fake()->randomFloat(2, 0, 2000),
            'status'           => fake()->randomElement(['paid', 'unpaid', 'cancelled']),
            'payment_method'   => fake()->randomElement(['cash', 'online', 'points']),
            'is_delivery'      => $isDelivery,
            'delivery_address' => $isDelivery ? fake()->address() : null,
            'delivery_status'  => $isDelivery
                ? fake()->randomElement(['pending', 'preparing', 'out_for_delivery', 'delivered'])
                : 'not_applicable',
            'delivery_fee'     => $isDelivery ? 5000.00 : 0.00,
            'created_at'       => fake()->dateTimeBetween('-3 months', 'now'),
        ];
    }
}
