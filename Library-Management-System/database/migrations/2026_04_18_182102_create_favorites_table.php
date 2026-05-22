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
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();

            
            $table->foreignId('customer_id')
                  ->constrained('customers')
                  ->onDelete('cascade');

            // ربط المفضلة بالكتاب
            $table->foreignId('book_id')
                  ->constrained('books')
                  ->onDelete('cascade');

            $table->timestamps();

            // منع تكرار إضافة نفس الكتاب لنفس العميل مرتين
            $table->unique(['customer_id', 'book_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};