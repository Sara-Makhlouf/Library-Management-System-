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
        Schema::create('cart_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cart_id')->constrained()->onDelete('cascade');
            $table->foreignId('book_id')->constrained()->onDelete('cascade');

            $table->decimal('price', 10, 2);
            
            // إضافة حقل النوع (buy أو borrow)
            $table->enum('type', ['buy', 'borrow'])->default('borrow');
            
            // جعل تاريخ الاستحقاق اختيارياً (nullable)
            $table->timestamp('due_at')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cart_details');
    }
};