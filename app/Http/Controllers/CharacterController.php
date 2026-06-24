<?php
namespace App\Http\Controllers;

use Inertia\Inertia;
use App\Models\Character;
use App\Models\Race;
use App\Models\CharacterClass;
use App\Models\Item;
use App\Models\Ability;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log; 
use Illuminate\Support\Facades\DB;

class CharacterController extends Controller
{
    public function addExperience(Request $request, Character $character)
{
    // Валидация: опыт должен быть положительным целым числом
    $request->validate([
        'xp' => 'required|integer|min:1|max:10000',
    ]);

    // Вызываем хранимую функцию PostgreSQL
    $result = DB::select('SELECT level_up_character(?, ?) as message', [
        $character->id,
        $request->input('xp')
    ]);

    $message = $result[0]->message;

    // Перенаправляем обратно на страницу персонажа с сообщением
    return redirect()->back()->with('success', $message);
}
    public function store(Request $request)
{
    $request->validate([
        'name' => 'required|string|max:255',
    ]);

    $race = Race::inRandomOrder()->first();
    $charClass = CharacterClass::inRandomOrder()->first();

    if (!$race || !$charClass) {
        return redirect()->back()->withErrors('Нет доступных рас или классов');
    }

    $character = Character::create([
        'user_id'      => Auth::id(),
        'name'         => $request->name,
        'race_id'      => $race->id,
        'class_id'     => $charClass->id,
        'level'        => 1,
        'experience'   => 0,
        'strength'     => rand(8, 18),
        'dexterity'    => rand(8, 18),
        'intelligence' => rand(8, 18),
        'iconstitution'=> rand(8, 18),
        'wisdom'       => rand(8, 18),
        'charisma'     => rand(8, 18),
        'health_max'   => rand(6, 15),
        'gold'         => rand(1, 15),
        'copper'       => rand(0, 99),
        'silver'       => rand(0, 99),
    ]);
    $itemsCount = rand(1, 5);
    $randomItems = Item::inRandomOrder()->limit($itemsCount)->get();
    foreach ($randomItems as $item) {
        $character->items()->attach($item->id, ['quantity' => 1]);
    }

    // Добавляем ровно 3 случайные способности
    $randomAbilities = Ability::inRandomOrder()->limit(3)->get();
    $character->abilities()->attach($randomAbilities->pluck('id')->toArray());
    return redirect()->back()->with('success', "Персонаж {$character->name} создан!");

}
public function destroy(Character $character)
{
    // Проверяем, что персонаж принадлежит текущему пользователю
    if ($character->user_id !== Auth::id()) {
        return redirect()->back(303)->withErrors('Нельзя удалить чужого персонажа');
    }

    $character->delete();

    // Статус 303 гарантирует, что следующий запрос будет GET
    return redirect()->back(303)->with('success', 'Персонаж удалён');
}
public function show(Character $character)
{
    if ($character->user_id !== Auth::id()) {
        abort(403);
    }
    $character->load('race', 'characterClass', 'items', 'abilities');
    return Inertia::render('Character/Show', ['character' => $character]);
}

}