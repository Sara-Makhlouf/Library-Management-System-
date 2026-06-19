<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\Factory;

class CustomerFactory extends Factory
{
    protected $model = Customer::class;

    public function definition(): array
    {
        $user = User::factory()->create(['type' => 'customer']);

        return [
            'user_id'             => $user->id,
            'name'                => $user->name,
            'gender'              => fake()->randomElement(['M', 'F']),
            'DOB'                 => fake()->date('Y-m-d', '-20 years'),
            'phone'               => '09' . fake()->unique()->numerify('########'),
            'lang'                => fake()->randomElement(['ar', 'en']),
            'address'             => fake()->address(),
            'points_balance'      => fake()->numberBetween(0, 500),
            'max_borrowing_limit' => 3,
        ];
    }
}
