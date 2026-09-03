<script setup lang="ts">
import { RouterLink } from 'vue-router'
</script>

<template>
  <main class="home">
    <div class="content">
      <h1>SE Assignment</h1>
      <p class="subtitle">Select a task:</p>

      <div class="task-grid">
        <RouterLink to="/age" class="task-card">
          <div class="icon">♙</div>
          <h2>Task 1</h2>
          <p>Age Classification</p>
          <span class="arrow">→</span>
        </RouterLink>

        <RouterLink to="/pi" class="task-card">
          <div class="icon pi-icon">π</div>
          <h2>Task 2</h2>
          <p>Calculate PI</p>
          <span class="arrow">→</span>
        </RouterLink>

        <RouterLink to="/invoices" class="task-card">
          <div class="icon">▤</div>
          <h2>Task 3</h2>
          <p>Invoices &amp; Payments</p>
          <span class="arrow">→</span>
        </RouterLink>
      </div>
    </div>

    <footer>
      SE Assignment – Oracle + PL/SQL + Vue.js
    </footer>
  </main>
</template>

<style scoped>
.home {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f8fafc;
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
  color: #111827;
}

.content {
  flex: 1;
  width: min(1200px, calc(100% - 48px));
  margin: 0 auto;
  padding: 70px 0;
}

h1 {
  margin: 0;
  font-size: 3rem;
  font-weight: 750;
  letter-spacing: -0.04em;
}

.subtitle {
  margin: 18px 0 42px;
  font-size: 1.25rem;
  color: #6b7280;
}

.task-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.task-card {
  min-height: 330px;
  padding: 38px 28px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  text-decoration: none;
  text-align: center;
  color: white;

  background: linear-gradient(145deg, #2563eb, #3b82f6);
  border-radius: 16px;

  box-shadow: 0 12px 28px rgba(37, 99, 235, 0.18);

  transition:
    transform 160ms ease,
    box-shadow 160ms ease,
    filter 160ms ease;

  cursor: pointer;
  user-select: none;
}

.task-card:hover {
  transform: translateY(-7px);
  box-shadow: 0 20px 38px rgba(37, 99, 235, 0.3);
  filter: brightness(1.06);
}

.task-card:active {
  transform: translateY(-1px) scale(0.98);
  box-shadow: 0 7px 16px rgba(37, 99, 235, 0.25);
  filter: brightness(0.96);
}

.task-card:focus-visible {
  outline: 4px solid rgba(37, 99, 235, 0.3);
  outline-offset: 5px;
}

.icon {
  width: 82px;
  height: 82px;

  display: flex;
  align-items: center;
  justify-content: center;

  margin-bottom: 24px;

  border-radius: 50%;
  background: rgba(255, 255, 255, 0.14);

  font-size: 2.4rem;
  font-weight: 300;
}

.pi-icon {
  font-family: Georgia, serif;
  font-style: italic;
  font-size: 3rem;
}

.task-card h2 {
  margin: 0;
  font-size: 2rem;
  font-weight: 700;
}

.task-card p {
  margin: 16px 0 0;
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.95);
}

.arrow {
  margin-top: 30px;
  font-size: 2rem;
  line-height: 1;
  transition: transform 160ms ease;
}

.task-card:hover .arrow {
  transform: translateX(6px);
}

footer {
  padding: 28px 20px;
  text-align: center;

  color: #6b7280;
  background: #f1f5f9;
  border-top: 1px solid #e5e7eb;
}

@media (max-width: 850px) {
  .task-grid {
    grid-template-columns: 1fr;
  }

  .task-card {
    min-height: 240px;
  }

  .content {
    padding-top: 40px;
  }

  h1 {
    font-size: 2.4rem;
  }
}
</style>
