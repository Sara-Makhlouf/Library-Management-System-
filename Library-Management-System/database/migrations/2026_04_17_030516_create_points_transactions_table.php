<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('points_transactions', function (Blueprint $table) {
            $table->id(); // bigint id PK

            // الربط مع العميل
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();

            $table->integer('points_amount'); // (يمكن أن تكون سالبة للخصم وموجبة للكسب)

            // نوع العملية: مثلاً كسب من قراءة كتاب، أو خصم عند شراء
            $table->enum('transaction_type', ['earn', 'redeem', 'refund']); 
            $table->string('reason')->nullable();

            $table->timestamp('created_at')->useCurrent(); 
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('points_transactions');
    }
};
