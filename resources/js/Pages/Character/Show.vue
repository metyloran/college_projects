<script setup>
import { router } from '@inertiajs/vue3'
import { computed, ref } from 'vue'

const props = defineProps({
    character: Object,
})

const goBack = () => {
    router.get('/dashboard')
}

const getModifier = (score) => {
    return Math.floor((score - 10) / 2)
}

// Данные для добавления опыта
const xpValue = ref(100)
const xpProcessing = ref(false)
const xpError = ref(null)

const addXp = () => {
    xpError.value = null
    xpProcessing.value = true

    router.post(`/character/${props.character.id}/add-xp`, {
        xp: xpValue.value
    }, {
        preserveScroll: true,
        onSuccess: () => {
            xpProcessing.value = false
            router.reload({ only: ['character'] })
        },
        onError: (errors) => {
            xpError.value = errors.xp || 'Ошибка добавления опыта'
            xpProcessing.value = false
        }
    })
}

const nextLevelXp = computed(() => {
    const lvl = props.character.level
    return 100 * (lvl * lvl)
})
</script>

<template>
    <div class="detail-wrapper">
        <div class="detail-container">
            <!-- Кнопка назад -->
            <button @click="goBack" class="back-btn">
                ← Назад к списку
            </button>

            <!-- Карточка персонажа -->
            <div class="detail-card">
                <!-- Заголовок -->
                <div class="detail-header">
                    <div class="header-left">
                        <h1 class="char-name">{{ character.name }}</h1>
                        <p class="char-meta">
                            {{ character.race?.name || '?' }} · {{ character.character_class?.name || '?' }} · Уровень {{ character.level }}
                        </p>
                    </div>
                    <div class="header-right">
                        <div class="health-label">Здоровье</div>
                        <div class="health-value">{{ character.health_max }} HP</div>
                    </div>
                </div>

                <!-- Описание расы и класса -->
                <div class="desc-section">
                    <div class="desc-block">
                        <h2 class="desc-title">Расовая черта</h2>
                        <p class="desc-text">{{ character.race?.description || 'Нет описания' }}</p>
                    </div>
                    <div class="desc-block">
                        <h2 class="desc-title">Особенности класса</h2>
                        <p class="desc-text">{{ character.character_class?.description || 'Нет описания' }}</p>
                    </div>
                </div>

                <!-- Характеристики -->
                <div class="stats-section">
                    <h2 class="section-title">Характеристики</h2>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value">{{ character.strength }}</div>
                            <div class="stat-label">Сила ({{ getModifier(character.strength) >= 0 ? '+' : '' }}{{ getModifier(character.strength) }})</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">{{ character.dexterity }}</div>
                            <div class="stat-label">Ловкость ({{ getModifier(character.dexterity) >= 0 ? '+' : '' }}{{ getModifier(character.dexterity) }})</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">{{ character.iconstitution }}</div>
                            <div class="stat-label">Выносливость ({{ getModifier(character.iconstitution) >= 0 ? '+' : '' }}{{ getModifier(character.iconstitution) }})</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">{{ character.intelligence }}</div>
                            <div class="stat-label">Интеллект ({{ getModifier(character.intelligence) >= 0 ? '+' : '' }}{{ getModifier(character.intelligence) }})</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">{{ character.wisdom }}</div>
                            <div class="stat-label">Мудрость ({{ getModifier(character.wisdom) >= 0 ? '+' : '' }}{{ getModifier(character.wisdom) }})</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value">{{ character.charisma }}</div>
                            <div class="stat-label">Харизма ({{ getModifier(character.charisma) >= 0 ? '+' : '' }}{{ getModifier(character.charisma) }})</div>
                        </div>
                    </div>
                </div>

                <!-- Опыт и деньги -->
                <div class="wealth-exp">
                    <div>
                        <span class="label-muted">Опыт</span>
                        <div class="value-large">{{ character.experience }} XP</div>
                        <div class="text-sm text-gray-600">
                            До следующего уровня: {{ nextLevelXp - character.experience }} XP
                        </div>
                    </div>
                    <div>
                        <span class="label-muted">Сокровища</span>
                        <div class="value-large">{{ character.gold }} зол. · {{ character.silver }} сер. · {{ character.copper }} мед.</div>
                    </div>
                </div>

                <!-- Инвентарь -->
                <div class="items-section">
                    <h2 class="section-title">Инвентарь</h2>
                    <div v-if="character.items && character.items.length" class="items-list">
                        <div v-for="item in character.items" :key="item.id" class="item-card">
                            <!-- Верхняя строка: название + количество -->
                            <div class="item-header">
                                <div class="item-name">{{ item.name }}</div>
                                <div class="item-quantity">x{{ item.pivot.quantity }}</div>
                            </div>
                            <!-- Описание и тип -->
                            <div class="item-desc">{{ item.description || 'Нет описания' }}</div>
                            <div class="item-meta">Тип: {{ item.item_type }} · Редкость: {{ item.rarity }}</div>
                            <!-- Характеристики (по центру) -->
                            <div class="item-char">
                                <div>+{{ item.strength }} к Силе</div>
                                <div>+{{ item.agility }} к Ловкости</div>
                                <div>+{{ item.health_bonus }} к здоровью</div>
                                <div>+{{ item.defense_bonus }} к защите</div>
                                <div>+{{ item.intelligence }} к Интеллекту</div>
                                <div>+{{ item.damage_bonus }} к атаке</div>
                            </div>
                            <!-- Цена (снизу справа) -->
                            <div class="item-cost">Стоимость: {{ item.price }}</div>
                        </div>
                    </div>
                    <div v-else class="empty-placeholder">Инвентарь пуст</div>
                </div>

                <!-- Способности -->
                <div class="abilities-section">
                    <h2 class="section-title">Способности</h2>
                    <div v-if="character.abilities && character.abilities.length" class="abilities-grid">
                        <div v-for="ability in character.abilities" :key="ability.id" class="ability-card">
                            <div class="ability-name">{{ ability.name }}</div>
                            <div class="ability-desc">{{ ability.description || 'Нет описания' }}</div>
                            <div class="ability-stats">
                                Тип: {{ ability.ability_type }} | 
                                Цена здоровья: {{ ability.health_cost }} | 
                                Урон: {{ ability.damage }} | 
                                Лечение: {{ ability.healing }}
                            </div>
                        </div>
                    </div>
                    <div v-else class="empty-placeholder">Нет способностей</div>
                </div>

                <!-- Добавление опыта -->
                <div class="xp-section p-4 bg-gray-100 rounded-lg mb-6 mx-4">
                    <h3 class="text-lg font-semibold mb-2">🏆 Добавить опыт</h3>
                    <form @submit.prevent="addXp">
                        <div class="flex gap-2">
                            <input 
                                v-model.number="xpValue" 
                                type="number" 
                                min="1"
                                placeholder="Количество опыта"
                                class="flex-1 border rounded px-3 py-2"
                                required
                            />
                            <button 
                                type="submit" 
                                :disabled="xpProcessing"
                                class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:opacity-50"
                            >
                                {{ xpProcessing ? 'Добавление...' : '➕ Добавить опыт' }}
                            </button>
                        </div>
                        <div v-if="xpError" class="text-red-500 text-sm mt-1">{{ xpError }}</div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</template>

<style scoped>
/* … (стили оставьте как у вас, они рабочие) … */
</style>

<style scoped>
/* Общий фон */
.detail-wrapper {
    min-height: 100vh;
    background: radial-gradient(circle at 10% 20%, #1e2a2e, #0f1722);
    padding: 2rem 1.5rem;
}

.detail-container {
    max-width: 1000px;
    margin: 0 auto;
}

/* Кнопка назад */
.back-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    background: rgba(0,0,0,0.4);
    color: #f3deba;
    padding: 0.6rem 1.2rem;
    border-radius: 2rem;
    font-family: 'MedievalSharp', cursive;
    cursor: pointer;
    transition: all 0.2s;
    margin-bottom: 1.5rem;
}

.back-btn:hover {
    background: #7a5a3a;
    transform: translateX(-4px);
}

/* Основная карточка */
.detail-card {
    background: #fef7e6;
    backdrop-filter: blur(8px);
    border-radius: 2rem;
    box-shadow: 0 20px 40px rgba(0,0,0,0.5);
    overflow: hidden;
}

/* Заголовок */
.detail-header {
    background: linear-gradient(135deg, #4a2f1f, #2a1a10);
    padding: 1.8rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 1rem;
    border-bottom: 1px solid #c6a15b;
    color: #f3deba;
}

.char-name {
    font-family: 'MedievalSharp', cursive;
    font-size: 2.2rem;
    color: #ffecb3;
    margin-bottom: 0.3rem;
}

.char-meta {
    color: #cfc394;
    font-size: 1rem;
}

.header-right {
    text-align: right;
    background: rgba(0,0,0,0.3);
    padding: 0.5rem 1.2rem;
    border-radius: 2rem;
}

.health-label {
    font-size: 0.8rem;
    opacity: 0.9;
    letter-spacing: 1px;
}

.health-value {
    font-size: 1.8rem;
    font-weight: bold;
    line-height: 1;
}

/* Описание расы/класса */
.desc-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    padding: 1.8rem 2rem;
    border-bottom: 1px solid #5e4b32;
}

.desc-title {
    font-size: 1rem;
    font-weight: 600;
    color: #2e251e;
    margin-bottom: 0.5rem;
}

.desc-text {
    color: #382b1f;
    font-size: 0.9rem;
    line-height: 1.4;
}

/* Характеристики */
.stats-section {
    padding: 1.5rem 2rem;
    border-bottom: 1px solid #5e4b32;
}

.section-title {
    font-size: 1.3rem;
    font-weight: bold;
    color: #382b1f;
    margin-bottom: 1rem;
    font-family: 'MedievalSharp', cursive;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
    gap: 1rem;
}

.stat-card {
    background: #2c241e;
    border-radius: 1rem;
    padding: 0.8rem;
    text-align: center;
    border: 1px solid #b58d4b;
}

.stat-value {
    font-size: 1.8rem;
    font-weight: bold;
    color: #f5cf8c;
}

.stat-label {
    font-size: 0.75rem;
    color: #bdae8a;
}

/* Опыт и деньги */
.wealth-exp {
    background: #1f1813;
    padding: 1.2rem 2rem;
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 1rem;
    border-bottom: 1px solid #7a5a3a;
}

.label-muted {
    color: #a58e6b;
    font-size: 0.8rem;
}

.value-large {
    font-size: 1.3rem;
    font-weight: bold;
    color: #f3deba;
}

/* Инвентарь — карточка предмета */
.items-section {
    padding: 1.5rem 2rem;
    border-bottom: 1px solid #5e4b32;
}

.items-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.item-card {
    background: #2a2019;
    border-radius: 1rem;
    padding: 1rem 1.2rem;
    border: 1px solid #8a6a42;
    display: flex;
    flex-direction: column;
}

.item-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-bottom: 0.5rem;
}

.item-name {
    font-weight: bold;
    font-size: 1.1rem;
    color: #e6c384;
}

.item-quantity {
    background: #c9a87b;
    color: #2a1a10;
    padding: 0.2rem 0.7rem;
    border-radius: 2rem;
    font-weight: bold;
    font-size: 0.8rem;
}

.item-desc {
    font-size: 0.85rem;
    color: #bcae8a;
    margin: 0.2rem 0;
}

.item-meta {
    font-size: 0.7rem;
    color: #8f7a5a;
    margin-bottom: 0.5rem;
}

.item-char {
    text-align: center;
    margin: 0.5rem 0;
    padding: 0.3rem 0;
    background: #3a2a1f;
    border-radius: 0.8rem;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
    gap: 1rem;
    
}

.item-char div {
    font-size: 0.75rem;
    color: #f2dcb2;
    margin: 0.1rem 0;
}

.item-cost {
    text-align: right;
    font-size: 0.85rem;
    font-weight: 600;
    color: #f5cf8c;
    margin-top: 0.3rem;
    border-top: 1px dashed #8a6a42;
    padding-top: 0.4rem;
}

/* Способности */
.abilities-section {
    padding: 1.5rem 2rem;
}

.abilities-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1rem;
}

.ability-card {
    background: #bfb35a;
    border-radius: 1rem;
    padding: 0.8rem;
    border-left: 4px solid #787453;
}

.ability-name {
    font-weight: bold;
    color: #363321;
    margin-bottom: 0.3rem;
}

.ability-desc {
    font-size: 0.8rem;
    color: #363321;
}

.ability-stats {
    font-size: 0.7rem;
    color: #363321;
    margin-top: 0.5rem;
}

.empty-placeholder {
    color: #9e8b70;
    font-style: italic;
    padding: 1rem;
    text-align: center;
    background: #1f1813;
    border-radius: 1rem;
}

/* Адаптивность */
@media (max-width: 700px) {
    .detail-header {
        flex-direction: column;
        align-items: flex-start;
        text-align: left;
    }
    .header-right {
        align-self: flex-start;
    }
    .desc-section {
        grid-template-columns: 1fr;
        gap: 1rem;
    }
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    .wealth-exp {
        flex-direction: column;
    }
}
</style>