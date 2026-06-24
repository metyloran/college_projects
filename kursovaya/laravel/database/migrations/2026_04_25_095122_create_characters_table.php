<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('characters', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->foreignId('race_id')->nullable()->constrained('races')->onDelete('set null');
            $table->foreignId('class_id')->nullable()->constrained('classes')->onDelete('set null');
            $table->integer('level')->default(1);
            $table->integer('experience')->default(0);
            $table->integer('strength')->default(10);
            $table->integer('dexterity')->default(10);
            $table->integer('intelligence')->default(10);
            $table->integer('iconstitution')->default(10);
            $table->integer('wisdom')->default(10);
            $table->integer('charisma')->default(10);
            $table->integer('health_max');
            $table->integer('gold')->default(0);
            $table->integer('copper')->default(0);
            $table->integer('silver')->default(0);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('characters');
    }
};