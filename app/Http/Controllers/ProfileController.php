<?php

namespace App\Http\Controllers;

use App\Models\Character;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class ProfileController extends Controller
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