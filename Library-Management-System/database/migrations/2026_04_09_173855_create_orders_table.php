<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('book_id')->constrained()->onDelete('cascade');

            $table->enum('type', ['borrow', 'sale'])->default('borrow');

            // هي الحقول خاصة بعملية الاستعارة فقط يعني لما بتكون حالة البيع "null"
            $table->date('borrow_date')->nullable(); // تاريخ بدء الاستعارة
            $table->date('due_date')->nullable();    // تاريخ الإرجاع المفترض
            $table->date('return_date')->nullable(); // التاريخ الفعلي الذي تم فيه إرجاع الكتاب
            $table->decimal('insurance_paid', 8, 2)->default(0); // مبلغ التأمين المدفوع (مسترد)
            $table->decimal('penalty_amount', 8, 2)->default(0); // غرامة التأخير أو الضرر بالنسخة

            $table->decimal('total_price', 8, 2);
            // حالات الطلب
            $table->enum('status', ['pending', 'active', 'completed', 'returned', 'overdue', 'cancelled'])->default('pending');
            $table->enum('payment_method', ['cash', 'online'])->default('cash');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
