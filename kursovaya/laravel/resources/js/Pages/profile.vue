<script setup>
defineProps({
  character: Object
})
</script>

<template>
  <div class="min-h-screen bg-gray-100 py-10 px-4">
    <div class="max-w-3xl mx-auto">

      <!-- Заголовок -->
      <h1 class="text-3xl font-bold text-gray-800 mb-6">
        👤 Профиль персонажа
      </h1>

      <!-- Если персонажа нет -->
      <div v-if="!character" class="bg-white p-6 rounded-xl shadow">
        <p class="text-gray-600">
          У тебя пока нет персонажа.
        </p>
      </div>

      <!-- Карточка персонажа -->
      <div v-else class="bg-white rounded-2xl shadow-lg overflow-hidden">

        <!-- Верхняя часть -->
        <div class="bg-gradient-to-r from-purple-500 to-indigo-600 p-6 text-white">
          <h2 class="text-2xl font-bold">
            🎮 Твой персонаж
          </h2>
          <p class="text-sm opacity-80">
            Уникальный герой твоего приключения
          </p>
        </div>

        <!-- Контент -->
        <div class="p-6 space-y-4">

          <!-- Race -->
          <div class="flex justify-between items-center border-b pb-3">
            <span class="text-gray-600">🏹 Раса</span>
            <span class="font-semibold text-gray-900">
              {{ character.race?.name }}
            </span>
          </div>

          <!-- Class -->
          <div class="flex justify-between items-center border-b pb-3">
            <span class="text-gray-600">⚔️ Класс</span>
            <span class="font-semibold text-gray-900">
              {{ character.class?.name }}
            </span>
          </div>

          <!-- User ID -->
          <div class="flex justify-between items-center">
            <span class="text-gray-600">🧑 Игрок</span>
            <span class="font-semibold text-gray-900">
              #{{ character.user_id }}
            </span>
          </div>

        </div>

        <!-- Нижняя кнопка -->
        <div class="p-6 bg-gray-50 flex justify-end">
          <button
            class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg transition"
          >
            🔄 Перегенерировать
          </button>
        </div>

      </div>
    </div>
  </div>
</template>