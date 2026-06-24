<?php

namespace App\Http\Controllers;

use App\Models\User;
use Inertia\Inertia;


class AdminController extends Controller
{
  
    public function index()
{
    $users = User::with(['characters.race', 'characters.characterClass', 'characters.items', 'characters.abilities'])->get();
    return Inertia::render('Admin/Index', ['users' => $users]);
}
}