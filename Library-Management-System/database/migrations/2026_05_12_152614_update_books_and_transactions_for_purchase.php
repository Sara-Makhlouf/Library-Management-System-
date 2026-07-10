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
    // تعديلات جدول الكتب
    Schema::table('books', function (Blueprint $table) {
        $table->decimal('sale_price', 8, 2)->nullable()->after('price'); // سعر البيع
        $table->boolean('is_available')->default(true)->after('stock'); // متاح للاستعارة أم لا
    });

    // تعديلات جدول العمليات
    Schema::table('transactions', function (Blueprint $table) {
        $table->string('type')->default('borrow')->after('book_id'); // borrow or buy
        
        // تعديل الـ Enum لإضافة حالة 'sold' (في لارافيل يفضل تغيير الحقل لـ string لسهولة التعامل)
        $table->string('status')->default('reserved')->change(); 
    });
}

    

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
