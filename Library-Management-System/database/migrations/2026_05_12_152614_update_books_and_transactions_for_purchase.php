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
    Schema::table('books', function (Blueprint $table) {
        if (!Schema::hasColumn('books', 'sale_price')) {
            $table->decimal('sale_price', 8, 2)->nullable()->after('price');
        }
        if (!Schema::hasColumn('books', 'is_available')) {
            $table->boolean('is_available')->default(true)->after('stock');
        }
    });

    Schema::table('transactions', function (Blueprint $table) {
        if (!Schema::hasColumn('transactions', 'type')) {
            $table->string('type')->default('borrow')->after('book_id');
        }
        if (!Schema::hasColumn('transactions', 'status')) {
            $table->string('status')->default('reserved')->change();
        }
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
