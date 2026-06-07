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
        Schema::create('books', function (Blueprint $table) {
            $table->id();
            $table->char('ISBN', 13)->unique();
            $table->string('title', 150)->index();
            $table->decimal('price', 8, 2)->default(0)->comment('سعر الإعارة');
            $table->decimal('sale_price', 8, 2)->default(0)->comment('سعر البيع');
            $table->string('cover')->nullable();
            $table->integer('total_pages')->nullable();

            $table->integer('borrow_duration')->default(7);
            $table->integer('total_copies')->default(0);
            $table->integer('stock')->default(0);
            $table->date('authorship_date')->nullable();
            $table->foreignId('category_id')->constrained()->cascadeOnDelete();

            $table->string('file_path')->nullable();
            $table->boolean('is_digital')->default(false);
            $table->softDeletes();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};
