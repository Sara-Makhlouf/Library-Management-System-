<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookmarks', function (Blueprint $table) {
            $table->id();

            // الربط مع العميل والكتاب
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete(); // bigint customer_id FK
            $table->foreignId('book_id')->constrained()->cascadeOnDelete(); // bigint book_id FK

            $table->integer('page_number');
            $table->string('note')->nullable();


            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookmarks');
    }
};
