<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ability extends Model
{
    protected $table = 'abilities';
    
    protected $fillable = [
        'name', 'description', 'ability_type', 'health_cost',
        'damage', 'healing', 'required_level'
    ];
    
    public function characters()
    {
        return $this->belongsToMany(Character::class, 'character_ability');
    }
}