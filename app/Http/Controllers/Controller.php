<?php

namespace App\Http\Controllers;

use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    public function index()
    {
        $character = Character::with(['race', 'class'])
            ->where('user_id', Auth::id())
            ->latest()
            ->first();

            return Inertia::render('Profile', [
                'character' => $character
            ]);
    }
}
