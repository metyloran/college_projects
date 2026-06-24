<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    protected $table = 'items';
    
    protected $fillable = [
        'name', 'description', 'item_type', 'rarity', 'level_required',
        'strength', 'agility', 'intelligence', 'health_bonus',
        'damage_bonus', 'defense_bonus', 'price'
    ];
    
    // Связь с персонажами (многие ко многим)
    public function characters()
    {
        return $this->belongsToMany(Character::class, 'character_item')
                    ->withPivot('quantity')
                    ->withTimestamps();
    }
}