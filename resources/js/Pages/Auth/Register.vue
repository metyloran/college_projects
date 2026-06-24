<script setup>
import { useForm } from '@inertiajs/vue3'

const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: ''
})

const submit = () => {
    form.post('/register')
}
</script>

<template>
    <div class="register-container">
        <form @submit.prevent="submit" class="register-form">
            <h1 class="form-title">📜 Регистрация 📜</h1>
            <p class="form-subtitle">Начни своё приключение в мире D&D</p>

            <div class="input-group">
                <label for="name">Имя искателя</label>
                <input 
                    id="name"
                    v-model="form.name" 
                    type="text" 
                    placeholder="Арагорн, Морриган..."
                    class="form-input"
                />
                <div v-if="form.errors.name" class="error-message">{{ form.errors.name }}</div>
            </div>

            <div class="input-group">
                <label for="email">Голубиная почта</label>
                <input 
                    id="email"
                    v-model="form.email" 
                    type="email" 
                    placeholder="hero@dungeon.com"
                    class="form-input"
                />
                <div v-if="form.errors.email" class="error-message">{{ form.errors.email }}</div>
            </div>

            <div class="input-group">
                <label for="password">Тайное слово</label>
                <input 
                    id="password"
                    v-model="form.password" 
                    type="password" 
                    placeholder="придумайте пароль..."
                    class="form-input"
                />
                <div v-if="form.errors.password" class="error-message">{{ form.errors.password }}</div>
            </div>

            <div class="input-group">
                <label for="password_confirmation">Подтверждение тайного слова</label>
                <input 
                    id="password_confirmation"
                    v-model="form.password_confirmation" 
                    type="password" 
                    placeholder="подтвердите пароль..."
                    class="form-input"
                />
                <div v-if="form.errors.password_confirmation" class="error-message">{{ form.errors.password_confirmation }}</div>
            </div>

            <button type="submit" :disabled="form.processing" class="submit-btn">
                <span v-if="!form.processing">Создать героя</span>
                <span v-else>Свиток заполняется...</span>
            </button>

            <div class="login-link">
                <span>Уже покоряете подземелья? </span>
                <a href="/login">Войти в таверну →</a>
            </div>
        </form>
    </div>
</template>

<style scoped>
.register-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: radial-gradient(circle at 10% 20%, #1e2a2e, #0f1722);
    padding: 1.5rem;
}

.register-form {
    background: rgba(25, 20, 16, 0.85);
    backdrop-filter: blur(8px);
    border-radius: 2rem;
    border: 1px solid rgba(218, 185, 110, 0.5);
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 245, 200, 0.1);
    padding: 2.5rem;
    width: 100%;
    max-width: 500px;
    transition: transform 0.2s ease;
}

.form-title {
    font-family: 'MedievalSharp', cursive;
    font-size: 2rem;
    text-align: center;
    background: linear-gradient(135deg, #f5e7c8, #dcb572);
    background-clip: text;
    -webkit-background-clip: text;
    color: transparent;
    margin-bottom: 0.5rem;
    letter-spacing: 2px;
}

.form-subtitle {
    text-align: center;
    color: #cdc2a3;
    margin-bottom: 2rem;
    font-size: 0.9rem;
    border-bottom: 1px dashed #c9a87b;
    display: inline-block;
    width: 100%;
    padding-bottom: 0.75rem;
}

.input-group {
    margin-bottom: 1.5rem;
}

.input-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #f3deba;
    font-size: 0.9rem;
    letter-spacing: 0.5px;
}

.form-input {
    width: 100%;
    padding: 0.85rem 1.2rem;
    background: #2c241e;
    border: 1px solid #b58d4b;
    border-radius: 1.2rem;
    color: #f3e3c2;
    font-size: 1rem;
    transition: all 0.2s;
    outline: none;
}

.form-input:focus {
    border-color: #e6b450;
    box-shadow: 0 0 0 3px rgba(230, 180, 80, 0.3);
    background: #1f1813;
}

.form-input::placeholder {
    color: #7a6a5a;
    font-style: italic;
}

.error-message {
    color: #e08e7a;
    font-size: 0.75rem;
    margin-top: 0.5rem;
    padding-left: 0.5rem;
    border-left: 3px solid #e08e7a;
}

.submit-btn {
    width: 100%;
    background: #7a5a3a;
    border: none;
    padding: 0.9rem;
    border-radius: 2rem;
    font-weight: bold;
    font-size: 1rem;
    font-family: 'MedievalSharp', cursive;
    letter-spacing: 1px;
    color: #fef0db;
    cursor: pointer;
    transition: all 0.2s;
    margin-top: 0.5rem;
    box-shadow: 0 4px 0 #4a3320;
}

.submit-btn:hover:not(:disabled) {
    background: #9b754b;
    transform: translateY(-2px);
    box-shadow: 0 6px 0 #4a3320;
}

.submit-btn:active:not(:disabled) {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #4a3320;
}

.submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
}

.login-link {
    text-align: center;
    margin-top: 2rem;
    font-size: 0.85rem;
    color: #bdae8a;
}

.login-link a {
    color: #e6b450;
    text-decoration: none;
    font-weight: 600;
    transition: color 0.2s;
}

.login-link a:hover {
    color: #f5cf8c;
    text-decoration: underline;
}

/* Адаптивность */
@media (max-width: 560px) {
    .register-form {
        padding: 1.8rem;
    }
    .form-title {
        font-size: 1.6rem;
    }
    .form-input {
        padding: 0.7rem 1rem;
    }
}
</style>