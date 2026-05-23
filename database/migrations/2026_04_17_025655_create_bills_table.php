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
        Schema::create('bills', function (Blueprint $table) {
            $table->id(); // bigint id PK

            // الربط مع جدول العملاء
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete(); // bigint customer_id FK

            // المبالغ المالية
            $table->decimal('total_price', 10, 2); // decimal total_price
            $table->decimal('discount_amount', 10, 2)->default(0); // decimal discount_amount (موجود في الصورة)

            // الحالات وطرق الدفع
            $table->enum('status', ['paid', 'unpaid', 'cancelled'])->default('unpaid'); // enum status
            $table->enum('payment_method', ['cash', 'online', 'points'])->nullable(); // enum payment_method

            $table->timestamps(); 
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bills');
    }
};
