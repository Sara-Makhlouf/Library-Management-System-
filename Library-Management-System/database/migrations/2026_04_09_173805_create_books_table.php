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
    $table->foreignId('category_id')->constrained()->onDelete('cascade');
    $table->string('title');
    $table->text('description');
    $table->string('cover_image')->nullable();
    $table->string('author_name')->nullable();

    $table->decimal('borrow_price', 8, 2);
    $table->decimal('insurance_fee', 8, 2);

    $table->decimal('sale_price', 8, 2)->nullable(); // سعر البيع (إذا فارغ يعني لا يباع)
    $table->boolean('allow_borrow')->default(true); // هل يسمح باستعارته؟
    $table->boolean('allow_sale')->default(false); // هل يسمح ببيعه؟

    $table->integer('stock_count')->default(1); //عدد النسخ الورقية الموجودة في المكتبة
    $table->string('pdf_path')->nullable(); // مسار ملف  PDF إذا كان الكتاب رقمياً
    $table->boolean('is_digital')->default(false);
    $table->boolean('is_available')->default(true);

    $table->integer('total_borrows')->default(0);// عدد مرات الاستعارة

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
