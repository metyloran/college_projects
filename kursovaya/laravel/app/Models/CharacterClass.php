<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CharacterClass extends Model
{
    protected $table = 'classes';
 
    
    protected $fillable = [
        'name',
        'description',
        'primary_attribute'
    ];
    
    // Связь с персонажами
    public function characters()
    {
        return $this->hasMany(Character::class, 'class_id');
    }
    public function characterClass()
    {
        return $this->belongsTo(CharacterClass::class, 'class_id');
    }
};
