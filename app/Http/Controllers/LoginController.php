<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        // Валидация входных данных
        $credentials = $request->validate([
            'name' => 'required|string',
            'password' => 'required|string',
        ]);

        // Попытка аутентификации по имени и паролю
        if (Auth::attempt(['name' => $credentials['name'], 'password' => $credentials['password']])) {
            // Регенерируем сессию для защиты от фиксации сессии
            $request->session()->regenerate();
            
            // Перенаправляем на дашборд
            return redirect()->intended(route('dashboard'));
        }

        // Если аутентификация не удалась
        return back()->withErrors([
            'name' => 'Неверное имя пользователя или пароль.',
        ])->onlyInput('name');
    }

    public function logout(Request $request)
    {
        // Выход из системы
        Auth::logout();
        
        // Инвалидируем сессию
        $request->session()->invalidate();
        
        // Регенерируем CSRF токен
        $request->session()->regenerateToken();
        
        // Перенаправляем на страницу входа
        return redirect('/login');
    }
}