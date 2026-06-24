<?php

use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CharacterController;
use App\Http\Controllers\LoginController;

// Laravel Breeze controllers
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\ConfirmablePasswordController;
use App\Http\Controllers\Auth\EmailVerificationNotificationController;
use App\Http\Controllers\Auth\EmailVerificationPromptController;
use App\Http\Controllers\Auth\NewPasswordController;
use App\Http\Controllers\Auth\PasswordController;
use App\Http\Controllers\Auth\PasswordResetLinkController;
use App\Http\Controllers\Auth\VerifyEmailController;
use App\Http\Controllers\AdminController;

Route::get('/', function () {
    return redirect()->route('login');
});

// Гости (неавторизованные)
Route::middleware('guest')->group(function () {
    Route::get('/register', fn () => Inertia::render('Auth/Register'))->name('register');
    Route::post('/register', [AuthController::class, 'register']);

    Route::get('/login', fn () => Inertia::render('Auth/Login'))->name('login');
    Route::post('/login', [LoginController::class, 'login']);
});

// Авторизованные пользователи
Route::middleware('auth')->group(function () {
    // Дашборд со списком персонажей (со всеми связями)
    Route::get('/dashboard', function () {
        $characters = \App\Models\Character::where('user_id', auth()->id())
            ->with('race', 'characterClass', 'items', 'abilities')
            ->get();
        return Inertia::render('Dashboard', [
            'characters' => $characters,
        ]);
    })->name('dashboard')->middleware('redirect.admin');
    Route::post('/character/{character}/add-xp', [CharacterController::class, 'addExperience'])
    ->name('character.add-xp');
    Route::middleware(['auth', 'admin'])->prefix('admin')->group(function () {
        Route::get('/', [AdminController::class, 'index'])->name('admin.index');
    });
    // Удаление персонажа
    Route::delete('/characters/{character}', [CharacterController::class, 'destroy'])
        ->name('characters.destroy');

    // Создание персонажа (через форму с именем)
    Route::post('/characters', [CharacterController::class, 'store'])
        ->name('characters.store');

    // Генерация полностью случайного персонажа (если нужен отдельный метод)
    Route::post('/characters/generate', [CharacterController::class, 'generate'])
        ->name('characters.generate');

    // Профиль
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile');

    // Маршруты для верификации email (Breeze)
    Route::get('/verify-email', EmailVerificationPromptController::class)->name('verification.notice');
    Route::get('/verify-email/{id}/{hash}', VerifyEmailController::class)
        ->middleware(['signed', 'throttle:6,1'])
        ->name('verification.verify');
    Route::post('/email/verification-notification', [EmailVerificationNotificationController::class, 'store'])
        ->middleware('throttle:6,1')
        ->name('verification.send');

    // Подтверждение пароля
    Route::get('/confirm-password', [ConfirmablePasswordController::class, 'show'])->name('password.confirm');
    Route::post('/confirm-password', [ConfirmablePasswordController::class, 'store']);

    // Обновление пароля
    Route::put('/password', [PasswordController::class, 'update'])->name('password.update');

    // Выход
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])->name('logout');
    Route::get('/character/{character}', [CharacterController::class, 'show'])->name('character.show');
});