<template>
    <div>
        <Navbar />
        
        <main class="py-4">
            <div class="container">
                <div class="text-center">
                    <h1 class="display-4">Добро пожаловать в RPG Character Generator</h1>
                    <p class="lead">Создавайте уникальных персонажей для ваших приключений!</p>
                    
                    <div v-if="!$page.props.auth.user" class="mt-4">
                        <Link :href="route('login')" class="btn btn-primary btn-lg me-2">
                            Войти
                        </Link>
                        <Link :href="route('register')" class="btn btn-success btn-lg">
                            Зарегистрироваться
                        </Link>
                    </div>
                    
                    <div v-else class="mt-4">
                        <Link :href="route('characters.index')" class="btn btn-primary btn-lg">
                            Мои персонажи
                        </Link>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import Navbar from '@/Components/Navbar.vue'
import { Link } from '@inertiajs/vue3'
</script>