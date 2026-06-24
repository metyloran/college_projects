<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('items', function (Blueprint $table) {
            $table->string('rarity')->default('common')->after('item_type');
            $table->integer('level_required')->default(1)->after('rarity');
            $table->integer('strength')->default(0)->after('level_required');
            $table->integer('agility')->default(0)->after('strength');
            $table->integer('intelligence')->default(0)->after('agility');
            $table->integer('health_bonus')->default(0)->after('intelligence');
            $table->integer('damage_bonus')->default(0)->after('health_bonus');
            $table->integer('defense_bonus')->default(0)->after('damage_bonus');
            $table->integer('price')->default(0)->after('defense_bonus');
        });
    }

    public function down()
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropColumn([
                'rarity', 'level_required', 'strength', 'agility', 'intelligence',
                'health_bonus', 'damage_bonus', 'defense_bonus', 'price'
            ]);
        });
    }
};