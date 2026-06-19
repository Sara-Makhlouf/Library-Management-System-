<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();

            $table->foreignId('customer_id')
                  ->constrained('customers')
                  ->cascadeOnDelete();

            $table->string('type');

            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable();

            $table->unsignedBigInteger('related_id')->nullable();
            $table->string('related_type')->nullable();

            $table->boolean('is_read')->default(false);
            $table->timestamp('sent_at')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['customer_id', 'is_read']);
            $table->index(['related_id', 'related_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
