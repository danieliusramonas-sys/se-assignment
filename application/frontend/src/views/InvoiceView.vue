<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'

type Invoice = {
  invoiceId: number
  invoiceDate: string
  invoiceAmount: number
  currency: string
  status: string
  debtAmount: number | null
}

type Payment = {
  paymentId: number
  invoiceId: number
  paymentDate: string
  paymentAmount: number
}

type PaymentOperationResult = {
  statusCode: string
  errorCode: number | null
  message: string
}

const invoices = ref<Invoice[]>([])
const payments = ref<Payment[]>([])

const invoiceId = ref<number | null>(null)
const status = ref('')

const selectedInvoiceId = ref<number | null>(null)

const invoicesLoading = ref(false)
const paymentsLoading = ref(false)
const paymentSubmitting = ref(false)

const error = ref<string | null>(null)
const operationMessage = ref<string | null>(null)

const showPaymentForm = ref(false)
const paymentDate = ref('')
const paymentAmount = ref<number | null>(null)
const paymentResult = ref<PaymentOperationResult | null>(null)

const selectedInvoice = computed(() => {
  if (selectedInvoiceId.value === null) {
    return null
  }

  return invoices.value.find(
    (invoice) => invoice.invoiceId === selectedInvoiceId.value,
  ) ?? null
})

const canAddPayment = computed(() => {
  return (
    invoiceId.value !== null &&
    invoices.value.length === 1 &&
    selectedInvoice.value !== null &&
    selectedInvoice.value.invoiceId === invoiceId.value &&
    selectedInvoice.value.status === 'UNPAID'
  )
})

async function loadInvoices() {
  invoicesLoading.value = true
  error.value = null

  try {
    const params = new URLSearchParams()

    if (invoiceId.value !== null) {
      params.set('invoiceId', invoiceId.value.toString())
    }

    if (status.value) {
      params.set('status', status.value)
    }

    const query = params.toString()
    const url = query
      ? `/api/task3/invoices?${query}`
      : '/api/task3/invoices'

    const response = await fetch(url)
    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.message ?? 'Failed to load invoices')
    }

    invoices.value = data

    if (invoiceId.value !== null && invoices.value.length === 1) {
      selectedInvoiceId.value = invoices.value[0].invoiceId
      await loadPayments(invoices.value[0].invoiceId)
    } else {
      selectedInvoiceId.value = null
      await loadPayments()
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Unexpected error'
  } finally {
    invoicesLoading.value = false
  }
}

async function loadPayments(id?: number) {
  paymentsLoading.value = true
  error.value = null

  try {
    const url =
      id !== undefined
        ? `/api/task3/payments?invoiceId=${id}`
        : '/api/task3/payments'

    const response = await fetch(url)
    const data = await response.json()

    if (!response.ok) {
      throw new Error(data.message ?? 'Failed to load payments')
    }

    payments.value = data
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Unexpected error'
  } finally {
    paymentsLoading.value = false
  }
}

async function selectInvoice(id: number) {
  selectedInvoiceId.value = id
  operationMessage.value = null
  await loadPayments(id)
}

async function showAllPayments() {
  selectedInvoiceId.value = null
  operationMessage.value = null
  await loadPayments()
}

async function clearFilters() {
  invoiceId.value = null
  status.value = ''
  selectedInvoiceId.value = null
  operationMessage.value = null
  closePaymentForm()

  await loadInvoices()
}

function openPaymentForm() {
  if (!canAddPayment.value) {
    return
  }

  showPaymentForm.value = true
  paymentDate.value = getToday()
  paymentAmount.value = null
  paymentResult.value = null
  operationMessage.value = null
}

function closePaymentForm() {
  showPaymentForm.value = false
  paymentDate.value = ''
  paymentAmount.value = null
  paymentResult.value = null
}

async function submitPayment() {
  if (!selectedInvoice.value) {
    return
  }

  if (!paymentDate.value || paymentAmount.value === null) {
    paymentResult.value = {
      statusCode: 'FAIL',
      errorCode: null,
      message: 'Payment date and amount must be provided',
    }
    return
  }

  paymentSubmitting.value = true
  paymentResult.value = null

  try {
    const response = await fetch('/api/task3/payments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        invoiceId: selectedInvoice.value.invoiceId,
        paymentDate: paymentDate.value,
        paymentAmount: paymentAmount.value,
      }),
    })

    const data = (await response.json()) as PaymentOperationResult

    if (!response.ok) {
      throw new Error(data.message ?? 'Failed to add payment')
    }

    paymentResult.value = data

    if (data.statusCode === 'OK') {
      const currentInvoiceId = selectedInvoice.value.invoiceId
      const message = data.message

      showPaymentForm.value = false
      paymentDate.value = ''
      paymentAmount.value = null
      paymentResult.value = null

      await loadInvoices()

      selectedInvoiceId.value = currentInvoiceId
      await loadPayments(currentInvoiceId)

      operationMessage.value = message
    }
  } catch (e) {
    paymentResult.value = {
      statusCode: 'FAIL',
      errorCode: null,
      message: e instanceof Error ? e.message : 'Failed to add payment',
    }
  } finally {
    paymentSubmitting.value = false
  }
}

function getToday(): string {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

function formatAmount(value: number | null | undefined) {
  if (value === null || value === undefined) {
    return '—'
  }

  return Number(value).toFixed(2)
}

onMounted(loadInvoices)
</script>

<template>
  <main class="page">
    <div class="card">
      <RouterLink to="/" class="back">
        ← Back
      </RouterLink>

      <h1>Task 3 – Invoices & Payments</h1>

      <p class="description">
        View invoices, payment status, outstanding debt and related payments
        calculated from Oracle data.
      </p>

      <form
        v-if="!showPaymentForm"
        class="filters"
        @submit.prevent="loadInvoices"
      >
        <div class="field">
          <label for="invoiceId">
            Invoice number
          </label>

          <input
            id="invoiceId"
            v-model.number="invoiceId"
            type="number"
            placeholder="Enter invoice number"
          />
        </div>

        <div class="field">
          <label for="status">
            Status
          </label>

          <select
            id="status"
            v-model="status"
          >
            <option value="">
              All
            </option>

            <option value="PAID">
              Paid
            </option>

            <option value="UNPAID">
              Unpaid
            </option>
          </select>
        </div>

        <button
          type="submit"
          :disabled="invoicesLoading"
        >
          {{ invoicesLoading ? 'Loading...' : 'Search' }}
        </button>

        <button
          type="button"
          class="secondary"
          :disabled="invoicesLoading"
          @click="clearFilters"
        >
          Clear
        </button>
      </form>

      <div
        v-if="error"
        class="error"
      >
        {{ error }}
      </div>

      <div
        v-if="operationMessage && !showPaymentForm"
        class="success-message"
      >
        {{ operationMessage }}
      </div>

      <section
        v-if="showPaymentForm && selectedInvoice"
        class="payment-entry"
      >
        <div class="section-header">
          <h2>Add Payment</h2>
        </div>

        <form
          class="payment-form"
          @submit.prevent="submitPayment"
        >
          <div class="field">
            <label for="paymentInvoiceId">
              Invoice ID
            </label>

            <input
              id="paymentInvoiceId"
              :value="selectedInvoice.invoiceId"
              type="number"
              disabled
            />
          </div>

          <div class="field">
            <label for="paymentCurrency">
              Currency
            </label>

            <input
              id="paymentCurrency"
              :value="selectedInvoice.currency"
              type="text"
              disabled
            />
          </div>

          <div class="field">
            <label for="currentDebt">
              Current debt
            </label>

            <input
              id="currentDebt"
              :value="formatAmount(selectedInvoice.debtAmount)"
              type="text"
              disabled
            />
          </div>

          <div class="field">
            <label for="paymentDate">
              Payment date
            </label>

            <input
              id="paymentDate"
              v-model="paymentDate"
              type="date"
            />
          </div>

          <div class="field">
            <label for="paymentAmount">
              Payment amount
            </label>

            <input
              id="paymentAmount"
              v-model.number="paymentAmount"
              type="number"
              step="0.01"
              placeholder="Enter payment amount"
            />
          </div>

          <div
            v-if="paymentResult"
            class="payment-result"
            :class="{
              success: paymentResult.statusCode === 'OK',
              failure: paymentResult.statusCode === 'FAIL',
            }"
          >
            <strong>
              {{ paymentResult.statusCode }}
            </strong>

            <span v-if="paymentResult.errorCode !== null">
              Error {{ paymentResult.errorCode }}
            </span>

            <span>
              {{ paymentResult.message }}
            </span>
          </div>

          <div class="payment-actions">
            <button
              type="button"
              class="secondary"
              :disabled="paymentSubmitting"
              @click="closePaymentForm"
            >
              Cancel
            </button>

            <button
              type="submit"
              :disabled="paymentSubmitting"
            >
              {{ paymentSubmitting ? 'Submitting...' : 'Submit' }}
            </button>
          </div>
        </form>
      </section>

      <template v-if="!showPaymentForm">
        <section class="section">
          <div class="section-header">
            <h2>Invoices</h2>

            <span class="row-count">
              {{ invoices.length }}
              record{{ invoices.length === 1 ? '' : 's' }}
            </span>
          </div>

          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th>Invoice No.</th>
                  <th>Date</th>
                  <th class="number">Amount</th>
                  <th>Currency</th>
                  <th>Status</th>
                  <th class="number">Debt</th>
                </tr>
              </thead>

              <tbody>
                <tr
                  v-for="invoice in invoices"
                  :key="invoice.invoiceId"
                  class="invoice-row"
                  :class="{
                    selected: selectedInvoiceId === invoice.invoiceId,
                  }"
                  @click="selectInvoice(invoice.invoiceId)"
                >
                  <td>
                    {{ invoice.invoiceId }}
                  </td>

                  <td>
                    {{ invoice.invoiceDate }}
                  </td>

                  <td class="number">
                    {{ formatAmount(invoice.invoiceAmount) }}
                  </td>

                  <td>
                    {{ invoice.currency }}
                  </td>

                  <td>
                    <span
                      class="status"
                      :class="invoice.status.toLowerCase()"
                    >
                      {{ invoice.status }}
                    </span>
                  </td>

                  <td
                    class="number"
                    :class="{
                      debt:
                        invoice.status === 'UNPAID' &&
                        invoice.debtAmount !== null &&
                        invoice.debtAmount > 0,
                    }"
                  >
                    {{
                      invoice.status === 'UNPAID'
                        ? formatAmount(invoice.debtAmount)
                        : '—'
                    }}
                  </td>
                </tr>

                <tr
                  v-if="!invoicesLoading && invoices.length === 0"
                >
                  <td
                    colspan="6"
                    class="empty"
                  >
                    No invoices found
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <div class="invoice-actions">
          <button
            type="button"
            class="add-payment"
            :disabled="!canAddPayment"
            @click="openPaymentForm"
          >
            Add Payment
          </button>
        </div>

        <section class="section payments-section">
          <div class="section-header">
            <h2>
              Payments

              <span
                v-if="selectedInvoiceId !== null"
                class="selected-invoice"
              >
                – Invoice {{ selectedInvoiceId }}
              </span>
            </h2>

            <button
              v-if="selectedInvoiceId !== null"
              type="button"
              class="show-all"
              @click="showAllPayments"
            >
              Show all payments
            </button>
          </div>

          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th>Payment ID</th>
                  <th>Invoice No.</th>
                  <th>Date</th>
                  <th class="number">Amount</th>
                </tr>
              </thead>

              <tbody>
                <tr
                  v-for="payment in payments"
                  :key="payment.paymentId"
                >
                  <td>
                    {{ payment.paymentId }}
                  </td>

                  <td>
                    {{ payment.invoiceId }}
                  </td>

                  <td>
                    {{ payment.paymentDate }}
                  </td>

                  <td class="number">
                    {{ formatAmount(payment.paymentAmount) }}
                  </td>
                </tr>

                <tr
                  v-if="!paymentsLoading && payments.length === 0"
                >
                  <td
                    colspan="4"
                    class="empty"
                  >
                    No payments found
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </template>
    </div>
  </main>
</template>

<style scoped>
.page {
  min-height: 100vh;
  padding: 28px 20px;
  background: #f5f7fa;
}

.card {
  width: 100%;
  max-width: 1100px;
  margin: 0 auto;
  padding: 40px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.08);
}

.back {
  display: inline-block;
  margin-bottom: 20px;
  color: #2563eb;
  font-weight: 600;
  text-decoration: none;
}

.back:hover {
  text-decoration: underline;
}

h1 {
  margin: 0 0 18px;
  font-size: 34px;
}

.description {
  margin-bottom: 28px;
  color: #64748b;
  font-size: 17px;
}

.filters {
  display: grid;
  grid-template-columns: 2fr 1.5fr auto auto;
  gap: 14px;
  align-items: end;
  margin-bottom: 28px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

label {
  font-weight: 600;
}

input,
select {
  width: 100%;
  box-sizing: border-box;
  padding: 12px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 9px;
  background: white;
  font-size: 16px;
}

input:disabled {
  background: #f1f5f9;
  color: #475569;
}

input:focus,
select:focus {
  outline: none;
  border-color: #2563eb;
}

button {
  padding: 12px 22px;
  border: none;
  border-radius: 9px;
  background: #2563eb;
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
}

button:hover:not(:disabled) {
  background: #1d4ed8;
}

button:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

button.secondary {
  background: #e2e8f0;
  color: #334155;
}

button.secondary:hover:not(:disabled) {
  background: #cbd5e1;
}

.error {
  margin-bottom: 24px;
  padding: 16px;
  border-radius: 9px;
  background: #fef2f2;
  color: #dc2626;
}

.success-message {
  margin-bottom: 24px;
  padding: 16px;
  border-radius: 9px;
  background: #f0fdf4;
  color: #166534;
  font-weight: 600;
}

.section {
  margin-top: 22px;
}

.payments-section {
  margin-top: 14px;
}

.invoice-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 14px;
}

.add-payment {
  background: #16a34a;
}

.add-payment:hover:not(:disabled) {
  background: #15803d;
}

.payment-entry {
  margin-top: 22px;
  padding: 24px;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  background: #f8fafc;
}

.payment-form {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}

.payment-result {
  grid-column: 1 / -1;
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 14px 16px;
  border-radius: 9px;
}

.payment-result.success {
  background: #f0fdf4;
  color: #166534;
}

.payment-result.failure {
  background: #fef2f2;
  color: #dc2626;
}

.payment-actions {
  grid-column: 1 / -1;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 10px;
}

h2 {
  margin: 0;
  font-size: 20px;
}

.selected-invoice {
  color: #64748b;
  font-size: 16px;
  font-weight: 500;
}

.row-count {
  color: #64748b;
  font-size: 14px;
}

.show-all {
  padding: 8px 14px;
  background: #e2e8f0;
  color: #334155;
  font-size: 14px;
}

.show-all:hover {
  background: #cbd5e1;
}

.table-scroll {
  max-height: 430px;
  overflow-y: auto;
  overflow-x: auto;
  border: 1px solid #e2e8f0;
  border-radius: 10px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  position: sticky;
  top: 0;
  z-index: 1;
  background: white;
}

th,
td {
  padding: 15px 12px;
  border-bottom: 1px solid #e2e8f0;
  text-align: left;
}

th {
  color: #475569;
  font-size: 14px;
  text-transform: uppercase;
}

tbody tr:last-child td {
  border-bottom: none;
}

.invoice-row {
  cursor: pointer;
}

.invoice-row:hover {
  background: #f8fafc;
}

.invoice-row.selected {
  background: #eff6ff;
}

.number {
  text-align: right;
}

.debt {
  color: #b91c1c;
  font-weight: 700;
}

.status {
  display: inline-block;
  min-width: 78px;
  padding: 5px 10px;
  border-radius: 999px;
  text-align: center;
  font-size: 13px;
  font-weight: 700;
}

.status.paid {
  background: #dcfce7;
  color: #166534;
}

.status.unpaid {
  background: #fee2e2;
  color: #991b1b;
}

.empty {
  padding: 30px;
  text-align: center;
  color: #64748b;
}

@media (max-width: 900px) {
  .filters {
    grid-template-columns: 1fr 1fr;
  }

  .payment-form {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 750px) {
  .filters,
  .payment-form {
    grid-template-columns: 1fr;
  }

  .card {
    padding: 24px;
  }

  h1 {
    font-size: 28px;
  }

  .section-header {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
