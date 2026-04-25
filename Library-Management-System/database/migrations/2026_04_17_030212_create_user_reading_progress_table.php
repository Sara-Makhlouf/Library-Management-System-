<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_reading_progress', function (Blueprint $table) {
            $table->id();

            // الربط مع العميل والكتاب
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('book_id')->constrained()->cascadeOnDelete(); 
            $table->integer('last_page_read')->default(0);


            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_reading_progress');
    }
};
