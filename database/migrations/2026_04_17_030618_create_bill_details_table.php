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
        Schema::create('bill_details', function (Blueprint $table) {
            $table->id();

            // الربط مع جدول الفواتير
            $table->foreignId('bill_id')->constrained()->cascadeOnDelete();

            // الربط مع جدول الكتب
            $table->foreignId('book_id')->constrained()->cascadeOnDelete();

            // الكمية المباعة
            $table->integer('quantity')->default(1);

            // سعر الوحدة   
            $table->decimal('unit_price', 10, 2);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bill_details');
    }
};
