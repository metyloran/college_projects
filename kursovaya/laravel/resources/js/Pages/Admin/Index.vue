<template>
  <div class="admin-wrapper">
    <div class="admin-container">
      <div class="admin-header">
        <h1 class="admin-title">👑 Админ-панель</h1>
        <button @click="logout" class="logout-btn">
                    Выйти из таверны
        </button>
      </div>

      <div class="users-list">
        <div v-for="user in users" :key="user.id" class="user-card">
          <div class="user-header">
            <div class="user-info">
              <span class="user-name">{{ user.name }}</span>
              <span class="user-email">{{ user.email }}</span>
              <span class="user-id">ID: {{ user.id }}</span>
              <span v-if="user.is_admin" class="admin-badge">Администратор</span>
            </div>
            <div class="user-stats">
              <span>🎭 Персонажей: {{ user.characters.length }}</span>
            </div>
          </div>

          <!-- Таблица персонажей пользователя -->
          <div v-if="user.characters.length" class="characters-table-wrapper">
            <table class="characters-table">
              <thead>
                <tr>
                  <th>Имя</th>
                  <th>Раса</th>
                  <th>Класс</th>
                  <th>Уровень</th>
                  <th>Сила</th>
                  <th>Ловк.</th>
                  <th>Здоровье</th>
                  <th>Золото</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="char in user.characters" :key="char.id">
                  <td>{{ char.name }}</td>
                  <td>{{ char.race?.name || '-' }}</td>
                  <td>{{ char.character_class?.name || '-' }}</td>
                  <td>{{ char.level }}</td>
                  <td>{{ char.strength }}</td>
                  <td>{{ char.dexterity }}</td>
                  <td>{{ char.health_max }}</td>
                  <td>{{ char.gold }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="no-characters">У пользователя нет персонажей</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { router } from '@inertiajs/vue3'

const props = defineProps({
  users: Array,
})

const goToDashboard = () => {
  router.get('/dashboard')
}
const logout = () => {
    router.post('/logout')
}
</script>

<style scoped>
.admin-wrapper {
  min-height: 100vh;
  
  padding: 2rem 1.5rem;
}

.admin-container {
  max-width: 1400px;
  margin: 0 auto;
}

.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #c9a87b;
}

.admin-title {
  font-family: 'MedievalSharp', cursive;
  font-size: 2rem;
  background: linear-gradient(135deg, #f5e7c8, #dcb572);
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
  letter-spacing: 2px;
}

.back-btn {
  background: #7a5a3a;
  border: none;
  padding: 0.5rem 1.2rem;
  border-radius: 2rem;
  color: #fef0db;
  font-family: 'MedievalSharp', cursive;
  cursor: pointer;
  transition: 0.2s;
}

.back-btn:hover {
  background: #9b754b;
  transform: translateX(-3px);
}

.users-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.user-card {
  background: rgba(25, 20, 16, 0.85);
  backdrop-filter: blur(4px);
  border-radius: 1.5rem;
  border: 1px solid #c9a87b;
  overflow: hidden;
  transition: 0.2s;
}

.user-header {
  background: #2a2019;
  padding: 1rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  border-bottom: 1px solid #7a5a3a;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1.2rem;
  flex-wrap: wrap;
}

.user-name {
  font-size: 1.3rem;
  font-weight: bold;
  color: #ffe6b3;
  font-family: 'MedievalSharp', cursive;
}

.user-email {
  color: #cdc2a3;
  font-size: 0.9rem;
}

.user-id {
  background: #1f1813;
  padding: 0.2rem 0.7rem;
  border-radius: 1rem;
  font-size: 0.75rem;
  color: #c9a87b;
}

.admin-badge {
  background: #7a2e2e;
  padding: 0.2rem 0.7rem;
  border-radius: 1rem;
  font-size: 0.7rem;
  color: #ffd6b3;
}

.user-stats {
  background: #1f1813;
  padding: 0.3rem 1rem;
  border-radius: 2rem;
  font-size: 0.9rem;
  color: #f3deba;
}

.characters-table-wrapper {
  overflow-x: auto;
  padding: 1rem;
}

.characters-table {
  width: 100%;
  border-collapse: collapse;
  background: #fef7e6;
  border-radius: 1rem;
  overflow: hidden;
}

.characters-table th,
.characters-table td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #d7caa5;
}

.characters-table th {
  background: #e6d5b3;
  color: #2c1e12;
  font-weight: 600;
  font-size: 0.85rem;
}

.characters-table td {
  color: #2c241e;
  font-size: 0.85rem;
}

.characters-table tr:hover {
  background: #f7efdc;
}

.no-characters {
  padding: 1rem 1.5rem 1.5rem;
  color: #bdae8a;
  font-style: italic;
}

@media (max-width: 700px) {
  .user-header {
    flex-direction: column;
    align-items: flex-start;
  }
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
</style>