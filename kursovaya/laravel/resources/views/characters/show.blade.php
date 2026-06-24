{{-- resources/views/characters/show.blade.php --}}
@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1>{{ $character->name }}</h1>
                <div>
                    <a href="{{ route('characters.download-document', $character) }}" 
                       class="btn btn-success">
                        📄 Скачать документ (DOCX)
                    </a>
                    <a href="{{ route('characters.index') }}" 
                       class="btn btn-secondary">
                        ← Назад
                    </a>
                </div>
            </div>
            
            @if(session('success'))
                <div class="alert alert-success">{{ session('success') }}</div>
            @endif
            
            <div class="row">
                <div class="col-md-6">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h4>📜 Основная информация</h4>
                        </div>
                        <div class="card-body">
                            <table class="table">
                                <tr><th>Раса:</th><td>{{ $character->race->name ?? '?' }}</td></tr>
                                <tr><th>Класс:</th><td>{{ $character->class->name ?? '?' }}</td></tr>
                                <tr><th>Уровень:</th><td>{{ $character->level }}</td></tr>
                                <tr><th>Опыт:</th><td>{{ $character->experience }}</td></tr>
                                <tr><th>Золото:</th><td>{{ number_format($character->gold) }} 💰</td></tr>
                            </table>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h4>⚔️ Характеристики</h4>
                        </div>
                        <div class="card-body">
                            <table class="table">
                                <tr><th>💪 Сила:</th><td>{{ $character->strength }}</td></tr>
                                <tr><th>🏃 Ловкость:</th><td>{{ $character->agility }}</td></tr>
                                <tr><th>🧠 Интеллект:</th><td>{{ $character->intelligence }}</td></tr>
                                <tr><th>❤️ Здоровье:</th><td>{{ $character->health_current }}/{{ $character->health_max }}</td></tr>
                                <tr><th>💙 Мана:</th><td>{{ $character->mana_current }}/{{ $character->mana_max }}</td></tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection