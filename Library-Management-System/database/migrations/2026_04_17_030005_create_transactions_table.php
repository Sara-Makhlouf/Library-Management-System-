<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bill_id')->constrained();
            $table->foreignId('book_id')->constrained();

            $table->decimal('price', 10, 2);
            $table->decimal('mortgage', 10, 2);
            $table->decimal('extra_price', 10, 2)->default(0);

            $table->timestamp('delivered_at');
            $table->timestamp('due_date')->nullable();
            $table->timestamp('returned_at')->nullable();;
            $table->decimal('customer_return_amount', 10, 2)->nullable();

            $table->enum('status', ['reserved', 'received', 'returned', 'expired']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
