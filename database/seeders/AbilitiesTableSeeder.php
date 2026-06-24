<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AbilitiesTableSeeder extends Seeder
{
    public function run()
    {
        DB::table('abilities')->insert([
            [
                'name' => 'Сильный удар',
                'description' => 'Наносит двойной урон',
                'ability_type' => 'attack',
                'health_cost' => 5,
                'damage' => 10,
                'healing' => 0,
                'required_level' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Легкая поступь',
                'description' => 'Увеличивает ловкость на 2',
                'ability_type' => 'buff',
                'health_cost' => 0,
                'damage' => 0,
                'healing' => 0,
                'required_level' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Огненный шар',
                'description' => 'Атакует всех врагов',
                'ability_type' => 'magic',
                'health_cost' => 8,
                'damage' => 15,
                'healing' => 0,
                'required_level' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Исцеление',
                'description' => 'Восстанавливает 10 HP',
                'ability_type' => 'heal',
                'health_cost' => 0,
                'damage' => 0,
                'healing' => 10,
                'required_level' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Боевой клич',
                'description' => 'Увеличивает силу группы',
                'ability_type' => 'buff',
                'health_cost' => 3,
                'damage' => 0,
                'healing' => 0,
                'required_level' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Щит',
                'description' => 'Уменьшает получаемый урон',
                'ability_type' => 'defense',
                'health_cost' => 4,
                'damage' => 0,
                'healing' => 0,
                'required_level' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}