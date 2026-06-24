<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('character_abilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('character_id')->constrained()->onDelete('cascade');
            $table->foreignId('ability_id')->constrained()->onDelete('cascade');
            $table->boolean('is_unlocked')->default(true);
            $table->integer('level')->default(1);
            $table->timestamps();
            
            $table->unique(['character_id', 'ability_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('character_abilities');
    }
};