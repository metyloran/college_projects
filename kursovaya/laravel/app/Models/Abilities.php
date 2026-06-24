<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Ability extends Model
{
    use HasFactory;

    protected $table = 'abilities';

    protected $fillable = [
        'name',
        'description',
        'ability_type',
        'health_cost',
        'damage',
        'healing',
        'required_level',
    ];

    protected $casts = [
        'health_cost' => 'integer',
        'damage' => 'integer',
        'healing' => 'integer',
        'required_level' => 'integer',
    ];

    /**
     * Способности принадлежат многим персонажам (связь many-to-many)
     */
    public function characters(): BelongsToMany
    {
        return $this->belongsToMany(Character::class, 'character_abilities')
                    ->withTimestamps();
    }
}