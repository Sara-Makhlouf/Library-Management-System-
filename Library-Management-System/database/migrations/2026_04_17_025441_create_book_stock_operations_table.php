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
        Schema::create('book_stock_operations', function (Blueprint $table) {
            $table->id();
            $table->integer('quantity');
            $table->enum('type', ['add', 'destroy']); // إضافة أو اتلاف
            $table->boolean('remove_from_remaining')->default(false);
            $table->foreignId('book_id')->constrained();
            $table->string('note')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('book_stock_operations');
    }
};
