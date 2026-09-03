<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

type PiResult = {
  precision: number
  calculatedPi: number
}

const precision = ref<number>(10)
const result = ref<PiResult | null>(null)
const loading = ref(false)
const error = ref<string | null>(null)

async function calculatePi() {
  result.value = null
  error.value = null

  if (precision.value < 1 || precision.value > 27) {
    error.value = 'Precision must be between 1 and 27'
    return
  }

  loading.value = true

  try {
    const response = await fetch('/api/task2/pi', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        precision: precision.value,
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.message ?? 'Failed to calculate PI')
    }

    result.value = data
  } catch (e) {
    error.value =
      e instanceof Error ? e.message : 'Unexpected error'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="page">
    <div class="card">
      <RouterLink to="/" class="back">← Back</RouterLink>

      <h1>Task 2 – Calculate PI</h1>

      <p class="description">
        Calculate PI using the Oracle CALCULATE_PI function.
      </p>

      <form @submit.prevent="calculatePi">
        <label for="precision">Precision (decimal places)</label>

        <input
          id="precision"
          v-model.number="precision"
          type="number"
          min="1"
          max="27"
          placeholder="Enter precision (1–27)"
        />

        <button type="submit" :disabled="loading">
          {{ loading ? 'Calculating...' : 'Calculate' }}
        </button>
      </form>

      <div v-if="error" class="error">
        {{ error }}
      </div>

      <div v-if="result" class="result">
        <div>
          <span>Precision</span>
          <strong>{{ result.precision }}</strong>
        </div>

        <div>
          <span>Calculated PI</span>
          <strong>{{ result.calculatedPi }}</strong>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
.page {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding: 28px 20px;
  background: #f5f7fa;
}

.card {
  width: 100%;
  max-width: 770px;
  padding: 40px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.08);
}

.back {
  display: inline-block;
  margin-bottom: 20px;
  color: #2563eb;
  text-decoration: none;
  font-weight: 600;
}

.back:hover {
  text-decoration: underline;
}

h1 {
  margin: 0 0 22px;
  font-size: 34px;
}

.description {
  margin-bottom: 34px;
  color: #64748b;
  font-size: 17px;
}

form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

label {
  font-weight: 600;
}

input {
  padding: 14px 16px;
  border: 1px solid #cbd5e1;
  border-radius: 9px;
  font-size: 17px;
}

input:focus {
  outline: none;
  border-color: #2563eb;
}

button {
  padding: 14px;
  border: none;
  border-radius: 9px;
  background: #2563eb;
  color: white;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
}

button:hover:not(:disabled) {
  background: #1d4ed8;
}

button:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.error {
  margin-top: 26px;
  padding: 16px;
  border-radius: 9px;
  background: #fef2f2;
  color: #dc2626;
}

.result {
  margin-top: 30px;
  padding-top: 24px;
  border-top: 1px solid #e2e8f0;
}

.result div {
  display: flex;
  justify-content: space-between;
  gap: 30px;
  margin: 14px 0;
}

.result span {
  color: #64748b;
}

.result strong {
  text-align: right;
}
</style>
