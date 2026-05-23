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
            $table->enum('gender', ['M', 'F']); 
            $table->date('DOB'); 
            $table->string('phone')->unique(); 
            $table->string('avatar')->nullable(); 
            $table->enum('lang', ['ar', 'en'])->default('ar'); 

            
            $table->text('address')->nullable();

            // الربط مع جدول المستخدمين
            $table->foreignId('user_id')->constrained()->unique()->cascadeOnDelete(); // bigint user_id FK

            // رصيد النقاط
            $table->integer('points_balance')->default(0); 

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
