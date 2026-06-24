<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::table('characters', function (Blueprint $table) {
        $table->integer('experience')->default(0)->change();
        $table->integer('wisdom')->default(10)->change();
        $table->integer('charisma')->default(10)->change();
        $table->integer('health_max')->default(100)->change();
        $table->integer('copper')->default(0)->change();
        $table->integer('silver')->default(0)->change();
        $table->integer('gold')->default(0)->change();
        // при необходимости: $table->integer('iconstitution')->nullable()->change();
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
