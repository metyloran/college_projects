<script setup>
import { router } from '@inertiajs/vue3'
import { useForm } from '@inertiajs/vue3'

const props = defineProps({
    characters: Array,
})

const form = useForm({
    name: '',
})

const goToAdmin = () => router.get('/admin')
const createCharacter = () => {
    form.post('/characters', {
        preserveScroll: true,
        onSuccess: () => {
            form.reset()
        },
        onError: (errors) => {
            console.error('Ошибки:', errors)
        },
    })
}

const deleteCharacter = (id, name) => {
    if (confirm(`Точно удалить персонажа "${name}"?`)) {
        router.delete(`${window.location.origin}/characters/${id}`, {
            preserveScroll: true,
        })
    }
}

const logout = () => {
    router.post('/logout')
}

// Функция перехода к детальной странице
const goToCharacter = (id) => {
    router.get(`/character/${id}`)
}
</script>

<template>
    <div class="dashboard-wrapper">
        <div class="dashboard-container">
            <!-- Шапка -->
            <div class="dashboard-header">
                <h1 class="dashboard-title">Созданные персонажи</h1>
                <button @click="logout" class="logout-btn">
                    Выйти из таверны
                </button>
               
            </div>

            <!-- Форма создания -->
            <div class="create-card">
                <h2 class="create-title">Создать нового искателя</h2>
                <div class="create-form">
                    <input 
                        v-model="form.name" 
                        type="text"
                        placeholder="Выпишите имя героя:"
                        class="name-input"
                    />
                    <button
                        @click="createCharacter"
                        :disabled="form.processing"
                        class="create-btn"
                    >
                        {{ form.processing ? 'Создание...' : 'Создать' }}
                    </button>
                </div>
                <div v-if="form.errors.name" class="error-msg">{{ form.errors.name }}</div>
            </div>

            <!-- Сетка карточек -->
            <div v-if="characters && characters.length" class="cards-grid">
                <div 
                    v-for="char in characters" 
                    :key="char.id" 
                    class="character-card"
                    @click="goToCharacter(char.id)"
                >
                    <!-- Кнопка удаления -->
                    <button 
                        @click.stop="deleteCharacter(char.id, char.name)"
                        class="delete-btn"
                        title="Удалить персонажа"
                    >
                        ✕
                    </button>

                    <!-- Заголовок карточки -->
                    <div class="card-header">
                        <h3 class="card-name">{{ char.name }}</h3>
                        <p class="card-subtitle">
                            {{ char.race?.name || '?' }} · {{ char.character_class?.name || '?' }} · Уровень {{ char.level }}
                        </p>
                    </div>

                    <!-- Основные параметры -->
                    <div class="card-body">
                        <!-- Характеристики -->
                        <div class="stats-grid">
                            <div class="stat">
                                <span class="stat-label">Сила</span>
                                <span class="stat-value">{{ char.strength }}</span>
                            </div>
                            <div class="stat">
                                <span class="stat-label">Ловкость</span>
                                <span class="stat-value">{{ char.dexterity }}</span>
                            </div>
                            <div class="stat">
                                <span class="stat-label">Интеллект</span>
                                <span class="stat-value">{{ char.intelligence }}</span>
                            </div>
                            <div class="stat">
                                <span class="stat-label">Выносливость</span>
                                <span class="stat-value">{{ char.iconstitution }}</span>
                            </div>
                            <div class="stat">
                                <span class="stat-label">Мудрость</span>
                                <span class="stat-value">{{ char.wisdom }}</span>
                            </div>
                            <div class="stat">
                                <span class="stat-label">Харизма</span>
                                <span class="stat-value">{{ char.charisma }}</span>
                            </div>
                        </div>

                        <!-- Жизни и опыт -->
                        <div class="health-exp">
                            <div><span class="text-muted">Здоровье</span><br><strong>{{ char.health_max }} HP</strong></div>
                            <div><span class="text-muted">Опыт</span><br><strong>{{ char.experience }} XP</strong></div>
                        </div>

                        <!-- Деньги -->
                        <div class="wealth">
                            <span>🟡 {{ char.gold }} зол.</span>
                            <span>⚪ {{ char.silver }} сер.</span>
                            <span>🟤 {{ char.copper }} мед.</span>
                        </div>

                        <!-- Инвентарь -->
                        <div v-if="char.items && char.items.length" class="inventory">
                            <div class="section-title">Инвентарь</div>
                            <div class="item-list">
                                <span v-for="item in char.items" :key="item.id" class="item-chip">
                                    {{ item.name }} (x{{ item.pivot.quantity }})
                                </span>
                            </div>
                        </div>

                        <!-- Способности -->
                        <div v-if="char.abilities && char.abilities.length" class="abilities">
                            <div class="section-title">Способности</div>
                            <div class="ability-list">
                                <span v-for="ability in char.abilities" :key="ability.id" class="ability-chip">
                                    {{ ability.name }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div v-else class="empty-state">
                <p>У вас пока нет персонажей. Создайте первого героя!</p>
            </div>
        </div>
    </div>
</template>

<style scoped>
/* Глобальный фон */
.dashboard-wrapper {
    min-height: 100vh;
    background: radial-gradient(circle at 10% 20%, #1e2a2e, #0f1722);
    padding: 2rem 1.5rem;
}

.dashboard-container {
    max-width: 1400px;
    margin: 0 auto;
}

/* Шапка */
.dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 0.75rem;
    border-bottom: 2px solid #c9a87b;
}

.dashboard-title {
    font-family: 'MedievalSharp', cursive;
    font-size: 2.2rem;
    background: linear-gradient(135deg, #f5e7c8, #dcb572);
    background-clip: text;
    -webkit-background-clip: text;
    color: transparent;
    letter-spacing: 2px;
}

.logout-btn {
    background: #7a2e2e;
    border: none;
    color: #fef0db;
    padding: 0.6rem 1.5rem;
    border-radius: 2rem;
    font-weight: bold;
    cursor: pointer;
    transition: 0.2s;
    font-family: 'MedievalSharp', cursive;
    letter-spacing: 1px;
    box-shadow: 0 3px 0 #4a1e1e;
}

.logout-btn:hover {
    background: #9e4040;
    transform: translateY(-2px);
    box-shadow: 0 5px 0 #4a1e1e;
}

/* Карточка создания */
.create-card {
    background: rgba(25, 20, 16, 0.75);
    backdrop-filter: blur(8px);
    border-radius: 1.5rem;
    
    padding: 1.5rem;
    margin-bottom: 2.5rem;
}

.create-title {
    font-size: 1.4rem;
    color: #f3deba;
    margin-bottom: 1rem;
    font-family: 'MedievalSharp', cursive;
}

.create-form {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
}

.name-input {
    flex: 1;
    background: #2c241e;
    border: 1px solid #b58d4b;
    border-radius: 2rem;
    padding: 0.8rem 1.2rem;
    color: #f3e3c2;
    font-size: 1rem;
    outline: none;
    transition: 0.2s;
}

.name-input:focus {
    border-color: #e6b450;
    box-shadow: 0 0 0 3px rgba(230, 180, 80, 0.3);
}

.create-btn {
    background: #7a5a3a;
    border: none;
    padding: 0.8rem 2rem;
    border-radius: 2rem;
    font-weight: bold;
    color: #fef0db;
    font-family: 'MedievalSharp', cursive;
    cursor: pointer;
    transition: 0.2s;
    box-shadow: 0 3px 0 #4a3320;
}

.create-btn:hover:not(:disabled) {
    background: #9b754b;
    transform: translateY(-2px);
    box-shadow: 0 5px 0 #4a3320;
}

.create-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.error-msg {
    color: #e08e7a;
    font-size: 0.8rem;
    margin-top: 0.5rem;
    border-left: 3px solid #e08e7a;
    padding-left: 0.5rem;
}

/* Сетка карточек */
.cards-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.8rem;
}

.character-card {
    background: #2b231dc9;
    backdrop-filter: blur(4px);
    border-radius: 1.5rem;
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
    cursor: pointer;
    position: relative;
    box-shadow: 0 8px 20px rgba(0,0,0,0.4);
}

.character-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 15px 30px rgba(0,0,0,0.5);
    border-color: #e6b450;
}

.delete-btn {
    position: absolute;
    top: 0.8rem;
    right: 0.8rem;
    background: #9e2e2e;
    color: white;
    border: none;
    border-radius: 50%;
    width: 2rem;
    height: 2rem;
    font-size: 1.2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: 0.2s;
    z-index: 2;
    font-weight: bold;
}

.delete-btn:hover {
    background: #c04444;
    transform: scale(1.05);
}

.card-header {
    background: linear-gradient(135deg, #4a2f1f, #2a1a10);
    padding: 1rem 1.2rem;
    padding-right: 3rem;
}

.card-name {
    font-size: 1.5rem;
    font-weight: bold;
    color: #ffecb3;
    font-family: 'MedievalSharp', cursive;
    margin-bottom: 0.2rem;
}

.card-subtitle {
    font-size: 0.8rem;
    color: #cfc394;
}

.card-body {
    padding: 1rem 1rem 1.2rem;
    background: #fef7e6;
    color: #2c241e;
}

/* Характеристики */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 0.6rem;
    margin-bottom: 1rem;
}

.stat {
    background: #e7dcc0;
    border-radius: 1rem;
    padding: 0.3rem;
    text-align: center;
}

.stat-label {
    font-size: 0.7rem;
    font-weight: bold;
    display: block;
    color: #5a3e2a;
}

.stat-value {
    font-size: 1.2rem;
    font-weight: 700;
    color: #2c1a0c;
}

/* Здоровье и опыт */
.health-exp {
    display: flex;
    justify-content: space-between;
    background: #fff1dc;
    padding: 0.6rem 1rem;
    border-radius: 1rem;
    margin-bottom: 0.8rem;
}

.text-muted {
    color: #6b4c2c;
    font-size: 0.7rem;
}

/* Деньги */
.wealth {
    display: flex;
    gap: 1rem;
    background: #f3e5c9;
    padding: 0.5rem 1rem;
    border-radius: 2rem;
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 0.8rem;
    justify-content: center;
}

/* Инвентарь и способности */
.inventory, .abilities {
    margin-top: 0.8rem;
}

.section-title {
    font-size: 0.75rem;
    font-weight: bold;
    text-transform: uppercase;
    color: #7a5a3a;
    margin-bottom: 0.3rem;
}

.item-list, .ability-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.3rem;
}

.item-chip {
    background: #d9cba3;
    padding: 0.2rem 0.7rem;
    border-radius: 1rem;
    font-size: 0.7rem;
    color: #2c1e12;
}

.ability-chip {
    background: #bfb36a;
    padding: 0.2rem 0.7rem;
    border-radius: 1rem;
    font-size: 0.7rem;
    color: #2e1a4a;

}

/* Пустое состояние */
.empty-state {
    text-align: center;
    padding: 3rem;
    background: rgba(0,0,0,0.4);
    border-radius: 2rem;
    color: #cfc394;
    font-size: 1.2rem;
}

/* Адаптивность */
@media (max-width: 640px) {
    .dashboard-title {
        font-size: 1.6rem;
    }
    .create-form {
        flex-direction: column;
    }
    .cards-grid {
        grid-template-columns: 1fr;
    }
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>