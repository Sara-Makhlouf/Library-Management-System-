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
        Schema::create('customers', function (Blueprint $table) {
            $table->id();
            $table->string('name')->index();
            $table->enum('gender', ['M', 'F'])->nullable();
            $table->date('DOB')->nullable();
            $table->string('phone')->unique();
            $table->string('avatar')->nullable();
            $table->enum('lang', ['ar', 'en'])->default('ar');
            $table->text('address')->nullable();

            // الربط مع المستخدم
            $table->foreignId('user_id')->constrained()->unique()->cascadeOnDelete();

            $table->integer('points_balance')->default(0);

            $table->integer('max_borrowing_limit')->default(3);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('customers');
    }
};
