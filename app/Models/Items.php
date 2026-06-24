<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Item extends Model
{
    use HasFactory;

    protected $table = 'items';

    protected $fillable = [
        'name',
        'description',
        'item_type',
        'rarity',
        'level_required',
        'strength',
        'agility',
        'intelligence',
        'health_bonus',
        'damage_bonus',
        'defense_bonus',
        'price',
    ];

    protected $casts = [
        'level_required' => 'integer',
        'strength' => 'integer',
        'agility' => 'integer',
        'intelligence' => 'integer',
        'health_bonus' => 'integer',
        'damage_bonus' => 'integer',
        'defense_bonus' => 'integer',
        'price' => 'integer',
    ];

    /**
     * Связь многие-ко-многим с персонажами (инвентарь)
     */
    public function characters(): BelongsToMany
    {
        return $this->belongsToMany(Character::class, 'character_items')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }
}