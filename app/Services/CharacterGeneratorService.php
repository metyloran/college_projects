<?php
// app/Services/CharacterGeneratorService.php

namespace App\Services;

use App\Models\Race;
use App\Models\Classes;
use App\Models\Ability;
use App\Models\Item;
use App\Models\Characters;
use App\Models\CharacterInventory;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CharacterGeneratorService
{
    /**
     * Генерация случайного персонажа
     */
    public function generateRandom($userId)
    {
        DB::beginTransaction();
        
        try {
            // 1. Выбираем случайную расу
            $race = Race::inRandomOrder()->first();
            
            // 2. Выбираем случайный класс
            $class = Classes::inRandomOrder()->first();
            
            // 3. Генерируем имя
            $name = $this->generateRandomName($race);
            
            // 4. Рассчитываем характеристики
            $level = rand(1, 10);
            $stats = $this->calculateStats($race, $class, $level);
            
            // 5. Создаём персонажа
            $character = Character::create([
                'user_id' => $userId,
                'name' => $name,
                'race_id' => $race->id,
                'class_id' => $class->id,
                'level' => $level,
                'experience' => rand(0, 1000),
                'health_current' => $stats['health_max'],
                'health_max' => $stats['health_max'],
                'mana_current' => $stats['mana_max'],
                'mana_max' => $stats['mana_max'],
                'gold' => rand(50, 500),
                'strength' => $stats['strength'],
                'agility' => $stats['agility'],
                'intelligence' => $stats['intelligence'],
            ]);
            
            // 6. Добавляем случайные способности (3-5 штук)
            $abilities = Ability::inRandomOrder()->limit(rand(3, 5))->get();
            foreach ($abilities as $ability) {
                $character->abilities()->attach($ability->id, [
                    'is_unlocked' => true,
                    'level' => rand(1, 3)
                ]);
            }
            
            // 7. Добавляем стартовый инвентарь
            $this->addStartingInventory($character);
            
            DB::commit();
            
            return $character->load(['race', 'class', 'abilities', 'inventory.item']);
            
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
    
    /**
     * Генерация случайного имени
     */
    private function generateRandomName($race)
    {
        $prefixes = [
            'Эльф' => ['Эл', 'Аэ', 'Лэ', 'Кэ', 'Фир', 'Лир'],
            'Орк' => ['Гро', 'Мро', 'Тро', 'Кро', 'Бро', 'Зро'],
            'Человек' => ['Ар', 'Бер', 'Ген', 'Ри', 'Аль', 'Эд'],
            'Гном' => ['Бро', 'Гри', 'Тори', 'Ки', 'Дури', 'Торин']
        ];
        
        $suffixes = [
            'Эльф' => ['рон', 'рис', 'лис', 'рин', 'эль', 'иэль'],
            'Орк' => ['маш', 'гнар', 'шак', 'лог', 'хел', 'гор'],
            'Человек' => ['тур', 'мунд', 'тор', 'альд', 'рик', 'берт'],
            'Гном' => ['м', 'н', 'к', 'с', 'р', 'л']
        ];
        
        $raceName = $race->name;
        $prefix = $prefixes[$raceName][array_rand($prefixes[$raceName])];
        $suffix = $suffixes[$raceName][array_rand($suffixes[$raceName])];
        
        $names = [
            "$prefix$suffix",
            ucfirst(Str::random(6)),
            "Странник $prefix",
            "Мастер $suffix",
            "$prefix-$suffix"
        ];
        
        return $names[array_rand($names)];
    }
    
    /**
     * Расчёт характеристик
     */
    private function calculateStats($race, $class, $level)
    {
        // Базовые значения
        $baseStrength = 10 + ($level - 1) * 2;
        $baseAgility = 10 + ($level - 1) * 2;
        $baseIntelligence = 10 + ($level - 1) * 2;
        
        // Случайные вариации
        $variation = rand(-3, 3);
        
        // Применяем бонусы расы
        $strength = $baseStrength + ($race->strength_bonus ?? 0) + $variation;
        $agility = $baseAgility + ($race->agility_bonus ?? 0) + $variation;
        $intelligence = $baseIntelligence + ($race->intelligence_bonus ?? 0) + $variation;
        
        // Здоровье и мана
        $healthMax = 100 + ($level - 1) * 20 + ($race->health_bonus ?? 0) + $strength * 5;
        $manaMax = 50 + ($level - 1) * 10 + $intelligence * 3;
        
        return [
            'strength' => max(1, $strength),
            'agility' => max(1, $agility),
            'intelligence' => max(1, $intelligence),
            'health_max' => max(50, $healthMax),
            'mana_max' => max(20, $manaMax)
        ];
    }
    
    /**
     * Добавление стартового инвентаря
     */
    private function addStartingInventory($character)
    {
        // Добавляем стартовое оружие
        $weapon = Item::where('item_type', 'weapon')
            ->where('level_required', '<=', $character->level)
            ->inRandomOrder()
            ->first();
            
        if ($weapon) {
            CharacterInventory::create([
                'character_id' => $character->id,
                'item_id' => $weapon->id,
                'quantity' => 1,
                'is_equipped' => true,
                'equipped_slot' => 'weapon'
            ]);
        }
        
        // Добавляем случайную броню
        $armor = Item::where('item_type', 'armor')
            ->where('level_required', '<=', $character->level)
            ->inRandomOrder()
            ->first();
            
        if ($armor) {
            CharacterInventory::create([
                'character_id' => $character->id,
                'item_id' => $armor->id,
                'quantity' => 1,
                'is_equipped' => true,
                'equipped_slot' => 'armor'
            ]);
        }
        
        // Добавляем зелья
        $potion = Item::where('item_type', 'consumable')
            ->where('name', 'like', '%зелье%')
            ->first();
            
        if ($potion) {
            CharacterInventory::create([
                'character_id' => $character->id,
                'item_id' => $potion->id,
                'quantity' => rand(3, 10),
                'is_equipped' => false
            ]);
        }
    }
}