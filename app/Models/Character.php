<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;   // правильный импорт
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Item;
use App\Models\Ability;

class Character extends Model
{
    protected $fillable = [
        'user_id', 'name', 'race_id', 'class_id',
        'level', 'experience',
        'strength', 'dexterity', 'intelligence', 'iconstitution',
        'wisdom', 'charisma', 'health_max', 'gold', 'copper', 'silver'
    ];
    public function items()
{
    return $this->belongsToMany(\App\Models\Item::class, 'character_item')
                ->withPivot('quantity')
                ->withTimestamps();
}

public function abilities()
{
    return $this->belongsToMany(\App\Models\Ability::class, 'character_ability');
}
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function race(): BelongsTo
    {
        return $this->belongsTo(Race::class);
    }

    public function characterClass()
{
    return $this->belongsTo(CharacterClass::class, 'class_id');
}

    
}