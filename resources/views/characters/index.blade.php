<h1>Мои персонажи</h1>

<form method="POST" action="{{ route('generate') }}">
    @csrf

    <label>Раса:</label>
    <select name="race_id">
    @foreach($races as $race)
        <option value="{{ $race->id }}">{{ $race->name }}</option>
    @endforeach
</select>

<select name="class_id">
    @foreach($classes as $class)
        <option value="{{ $class->id }}">{{ $class->name }}</option>
    @endforeach
</select>

    <button type="submit">Сгенерировать персонажа</button>
</form>

<hr>
@if(session('generated_character'))
    <hr>
    <h2>Сгенерированный персонаж:</h2>

    <div>
        <h3>{{ session('generated_character')->name }}</h3>
        <p>Раса: {{ session('generated_character')->race }}</p>
        <p>Класс: {{ session('generated_character')->class }}</p>
        <p>Background: {{ session('generated_character')->background }}</p>
    </div>
@endif
{{-- resources/views/profile/index.blade.php --}}

@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            
            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    {{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif
            
            @if(session('error'))
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    {{ session('error') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif
            
            <!-- Информация о пользователе -->
            <div class="card mb-4">
                <div class="card-header">
                    <h3>👤 Мой профиль</h3>
                </div>
                <div class="card-body">
                    <p><strong>Имя:</strong> {{ $user->name }}</p>
                    <p><strong>Email:</strong> {{ $user->email }}</p>
                    <p><strong>Зарегистрирован:</strong> {{ $user->created_at->format('d.m.Y') }}</p>
                </div>
            </div>
            
            <!-- Карточка персонажа -->
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3>🎮 Мой персонаж</h3>
                    <div>
                        <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#generateModal">
                            🎲 Рандомно создать персонажа
                        </button>
                        
                        @if($character)
                        <form action="{{ route('characters.destroy') }}" method="POST" class="d-inline">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Вы уверены, что хотите удалить персонажа?')">
                                🗑️ Удалить персонажа
                            </button>
                        </form>
                        @endif
                    </div>
                </div>
                
                <div class="card-body">
                    @if($character)
                        <div class="row">
                            <div class="col-md-6">
                                <h4>📜 Характеристики</h4>
                                <table class="table">
                                    <tr>
                                        <th>Раса:</th>
                                        <td>
                                            <span class="badge bg-primary fs-6">
                                                {{ $character->race->name ?? 'Не указана' }}
                                            </span>
                                            @if($character->race && $character->race->description)
                                                <p class="mt-2 text-muted">
                                                    <small>{{ $character->race->description }}</small>
                                                </p>
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Класс:</th>
                                        <td>
                                            <span class="badge bg-success fs-6">
                                                {{ $character->characterClass->name ?? 'Не указан' }}
                                            </span>
                                            @if($character->characterClass && $character->characterClass->description)
                                                <p class="mt-2 text-muted">
                                                    <small>{{ $character->characterClass->description }}</small>
                                                </p>
                                            @endif
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Создан:</th>
                                        <td>{{ $character->created_at->format('d.m.Y H:i') }}</td>
                                    </tr>
                                    <tr>
                                        <th>Обновлён:</th>
                                        <td>{{ $character->updated_at->format('d.m.Y H:i') }}</td>
                                    </tr>
                                </table>
                            </div>
                            
                            <div class="col-md-6 text-center">
                                <div class="border rounded p-3 bg-light">
                                    <i class="fas fa-user-circle fa-5x mb-3"></i>
                                    <h4>{{ $user->name }}</h4>
                                    <p class="mb-0">
                                        🏷️ {{ $character->race->name ?? '?' }} 
                                        ⚔️ {{ $character->characterClass->name ?? '?' }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    @else
                        <div class="text-center py-4">
                            <i class="fas fa-user-slash fa-4x text-muted mb-3"></i>
                            <h4>У вас пока нет персонажа</h4>
                            <p class="text-muted">Нажмите кнопку "Рандомно создать персонажа", чтобы начать игру</p>
                            <button type="button" class="btn btn-primary btn-lg" data-bs-toggle="modal" data-bs-target="#generateModal">
                                🎲 Создать первого персонажа
                            </button>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Модальное окно для генерации -->
<div class="modal fade" id="generateModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">🎲 Создание случайного персонажа</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Вы уверены, что хотите создать (или пересоздать) персонажа?</p>
                <div class="alert alert-info">
                    <strong>Как это работает:</strong>
                    <ul class="mb-0 mt-2">
                        <li>Раса и класс будут выбраны случайно из базы данных</li>
                        <li>Если у вас уже есть персонаж, он будет заменён новым</li>
                        <li>Все данные сохранятся в таблице characters</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Отмена</button>
                <form action="{{ route('characters.generate') }}" method="POST">
                    @csrf
                    <button type="submit" class="btn btn-primary">
                        🎲 Да, создать рандомного персонажа
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection