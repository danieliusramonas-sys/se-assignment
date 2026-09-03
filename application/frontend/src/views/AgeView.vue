<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

type AgeResult = {
  statusCode: string
  errorCode: number | null
  message: string
}

const age = ref<number | null>(null)
const result = ref<AgeResult | null>(null)
const loading = ref(false)
const error = ref<string | null>(null)

async function calculateAge() {
  result.value = null
  error.value = null

  if (age.value === null) {
    error.value = 'Age must be provided'
    return
  }

  loading.value = true

  try {
    const response = await fetch('/api/task1/age', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        age: age.value,
      }),
    })

    const text = await response.text()

    if (!text) {
      throw new Error('Backend returned an empty response')
    }

    const data = JSON.parse(text)

    if (!response.ok) {
      throw new Error(data.message ?? 'Failed to calculate age result')
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
    <div class="container">
      <RouterLink to="/" class="back-link">← Back</RouterLink>

      <section class="card">
        <h1>Task 1 – Age Classification</h1>
        <p class="description">
          Enter an age to classify it using the Oracle GET_AGE_RESULT function.
        </p>

        <form @submit.prevent="calculateAge" class="form">
          <label for="age">Age</label>

          <input
            id="age"
            v-model.number="age"
            type="number"
            min="-1"
            step="1"
            placeholder="Enter age"
          />

          <button type="submit" :disabled="loading">
            {{ loading ? 'Calculating...' : 'Calculate' }}
          </button>
        </form>

        <div v-if="error" class="message error">
          {{ error }}
        </div>

        <div v-if="result" class="result">
          <div>
            <span>Status</span>
            <strong>{{ result.statusCode }}</strong>
          </div>

          <div v-if="result.errorCode !== null">
            <span>Error code</span>
            <strong>{{ result.errorCode }}</strong>
          </div>

          <div>
            <span>Message</span>
            <strong>{{ result.message }}</strong>
          </div>
        </div>
      </section>
    </div>
  </main>
</template>

<style scoped>
.page {
  min-height: 100vh;
  background: #f8fafc;
  padding: 60px 24px;
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
}

.container {
  width: min(700px, 100%);
  margin: 0 auto;
}

.back-link {
  display: inline-block;
  margin-bottom: 24px;
  color: #2563eb;
  text-decoration: none;
  font-weight: 600;
}

.card {
  background: white;
  border-radius: 16px;
  padding: 36px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
}

h1 {
  margin-top: 0;
}

.description {
  color: #64748b;
  margin-bottom: 30px;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

label {
  font-weight: 600;
}

input {
  padding: 12px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font-size: 1rem;
}

input:focus {
  outline: 2px solid #2563eb;
  border-color: transparent;
}

button {
  margin-top: 8px;
  padding: 12px 18px;
  border: 0;
  border-radius: 8px;
  background: #2563eb;
  color: white;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
}

button:hover {
  background: #1d4ed8;
}

button:active {
  transform: scale(0.98);
}

button:disabled {
  opacity: 0.6;
  cursor: default;
}

.message {
  margin-top: 24px;
  padding: 14px;
  border-radius: 8px;
}

.error {
  background: #fef2f2;
  color: #b91c1c;
}

.result {
  margin-top: 28px;
  border-top: 1px solid #e2e8f0;
  padding-top: 20px;
}

.result div {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
}

.result span {
  color: #64748b;
}
</style>
