<?php
// app/Models/Race.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Race extends Model
{
    protected $fillable = ['name', 'description', 'strength_bonus', 'agility_bonus'];
    
    public function characters()
    {
        return $this->hasMany(Character::class);
    }
}