{{-- resources/views/characters/create.blade.php --}}
@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h3 class="mb-0">✨ Создание нового персонажа</h3>
                </div>
                <div class="card-body text-center">
                    <form action="{{ route('characters.generate') }}" method="POST">
                        @csrf
                        
                        <div class="mb-4">
                            <div class="alert alert-info">
                                <strong>🎲 Рандомная генерация</strong><br>
                                При нажатии кнопки будет создан уникальный персонаж со случайными параметрами:
                                <ul class="mt-2 text-start">
                                    <li>Случайная раса и класс</li>
                                    <li>Случайное имя</li>
                                    <li>Сбалансированные характеристики</li>
                                    <li>Стартовый инвентарь</li>
                                    <li>Уникальные способности</li>
                                </ul>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-lg px-5">
                            🎲 Рандомно создать персонажа
                        </button>
                        
                        <a href="{{ route('characters.index') }}" class="btn btn-secondary btn-lg px-5 ms-2">
                            ← Назад к списку
                        </a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection