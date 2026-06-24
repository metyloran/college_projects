@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h2>Добро пожаловать в RPG Character Generator!</h2>
                </div>
                <div class="card-body text-center">
                    @auth
                        <p>Вы вошли как: <strong>{{ auth()->user()->name }}</strong></p>
                        <a href="{{ route('characters.index') }}" class="btn btn-primary">
                            Перейти к персонажам
                        </a>
                    @else
                        <p>Создавайте уникальных персонажей для ваших RPG приключений!</p>
                        <div class="mt-4">
                            <a href="{{ route('login') }}" class="btn btn-primary me-2">Войти</a>
                            <a href="{{ route('register') }}" class="btn btn-success">Регистрация</a>
                        </div>
                    @endauth
                </div>
            </div>
        </div>
    </div>
</div>
@endsection