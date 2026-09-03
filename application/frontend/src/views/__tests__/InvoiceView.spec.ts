import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'

import InvoiceView from '../InvoiceView.vue'

const paidInvoice = {
  invoiceId: 1001,
  invoiceDate: '2026-01-01',
  invoiceAmount: 1000,
  currency: 'EUR',
  status: 'PAID',
  debtAmount: 0,
}

const unpaidInvoice = {
  invoiceId: 1002,
  invoiceDate: '2026-01-02',
  invoiceAmount: 750,
  currency: 'EUR',
  status: 'UNPAID',
  debtAmount: 250,
}

const invoices = [
  paidInvoice,
  unpaidInvoice,
]

const payments = [
  {
    paymentId: 501,
    invoiceId: 1001,
    paymentDate: '2026-01-03',
    paymentAmount: 1000,
  },
]

function response(data: unknown, ok = true) {
  return Promise.resolve({
    ok,
    json: async () => data,
  })
}

function createFetchMock() {
  return vi.fn().mockImplementation(
    (url: string, options?: RequestInit) => {
      if (
        url === '/api/task3/payments' &&
        options?.method === 'POST'
      ) {
        return response({
          statusCode: 'OK',
          errorCode: null,
          message: 'Payment successfully added',
        })
      }

      if (url === '/api/task3/invoices?invoiceId=1001') {
        return response([paidInvoice])
      }

      if (url === '/api/task3/invoices?invoiceId=1002') {
        return response([unpaidInvoice])
      }

      if (url === '/api/task3/invoices?status=UNPAID') {
        return response([unpaidInvoice])
      }

      if (url.startsWith('/api/task3/invoices')) {
        return response(invoices)
      }

      if (url.startsWith('/api/task3/payments')) {
        return response(payments)
      }

      throw new Error(`Unexpected URL: ${url}`)
    },
  )
}

function mountView() {
  return mount(InvoiceView, {
    global: {
      stubs: {
        RouterLink: true,
      },
    },
  })
}

async function searchInvoice(
  wrapper: ReturnType<typeof mountView>,
  invoiceId: number,
) {
  await wrapper.find('#invoiceId').setValue(invoiceId)

  await wrapper
    .find('form.filters')
    .trigger('submit')

  await flushPromises()
}

async function openPaymentForm(
  wrapper: ReturnType<typeof mountView>,
) {
  const button = wrapper.find('button.add-payment')

  expect(button.exists()).toBe(true)
  expect(button.attributes('disabled')).toBeUndefined()

  await button.trigger('click')
  await flushPromises()
}

describe('InvoiceView', () => {
  it('loads invoices and payments when view is opened', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/invoices',
    )

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments',
    )

    expect(wrapper.text()).toContain('1001')
    expect(wrapper.text()).toContain('1002')
    expect(wrapper.text()).toContain('PAID')
    expect(wrapper.text()).toContain('UNPAID')
    expect(wrapper.text()).toContain('250.00')
  })

  it('searches invoices by UNPAID status', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    fetchMock.mockClear()

    await wrapper.find('#status').setValue('UNPAID')

    await wrapper
      .find('form.filters')
      .trigger('submit')

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/invoices?status=UNPAID',
    )

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments',
    )
  })

  it('loads payments for selected invoice', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    fetchMock.mockClear()

    const invoiceRows = wrapper.findAll('.invoice-row')

    await invoiceRows[0].trigger('click')

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments?invoiceId=1001',
    )

    expect(
      wrapper.find('.selected-invoice').text(),
    ).toContain('Invoice 1001')
  })

  it('enables Add Payment for a specifically searched UNPAID invoice', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1002)

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/invoices?invoiceId=1002',
    )

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments?invoiceId=1002',
    )

    const addPaymentButton = wrapper.find(
      'button.add-payment',
    )

    expect(addPaymentButton.exists()).toBe(true)
    expect(
      addPaymentButton.attributes('disabled'),
    ).toBeUndefined()
  })

  it('keeps Add Payment disabled for a PAID invoice', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1001)

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/invoices?invoiceId=1001',
    )

    const addPaymentButton = wrapper.find(
      'button.add-payment',
    )

    expect(addPaymentButton.exists()).toBe(true)
    expect(
      addPaymentButton.attributes('disabled'),
    ).toBeDefined()
  })

  it('opens payment form with selected invoice data', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1002)
    await openPaymentForm(wrapper)

    expect(wrapper.find('.payment-form').exists()).toBe(true)

    expect(
      wrapper.find<HTMLInputElement>(
        '#paymentInvoiceId',
      ).element.value,
    ).toBe('1002')

    expect(
      wrapper.find<HTMLInputElement>(
        '#paymentCurrency',
      ).element.value,
    ).toBe('EUR')

    expect(
      wrapper.find<HTMLInputElement>(
        '#currentDebt',
      ).element.value,
    ).toBe('250.00')

    expect(
      wrapper.find<HTMLInputElement>(
        '#paymentDate',
      ).element.value,
    ).not.toBe('')

    expect(
      wrapper.find<HTMLInputElement>(
        '#paymentAmount',
      ).element.value,
    ).toBe('')
  })

  it('sends payment data to the backend', async () => {
    const fetchMock = createFetchMock()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1002)
    await openPaymentForm(wrapper)

    await wrapper
      .find('#paymentDate')
      .setValue('2026-09-03')

    await wrapper
      .find('#paymentAmount')
      .setValue('25.50')

    await wrapper
      .find('form.payment-form')
      .trigger('submit')

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          invoiceId: 1002,
          paymentDate: '2026-09-03',
          paymentAmount: 25.5,
        }),
      },
    )
  })

  it('shows Oracle business validation failure and keeps payment form open', async () => {
    const fetchMock = createFetchMock()

    fetchMock.mockImplementation(
      (url: string, options?: RequestInit) => {
        if (
          url === '/api/task3/payments' &&
          options?.method === 'POST'
        ) {
          return response({
            statusCode: 'FAIL',
            errorCode: -20039,
            message:
              'Payment amount exceeds outstanding debt',
          })
        }

        if (
          url === '/api/task3/invoices?invoiceId=1002'
        ) {
          return response([unpaidInvoice])
        }

        if (
          url.startsWith('/api/task3/invoices')
        ) {
          return response(invoices)
        }

        if (
          url.startsWith('/api/task3/payments')
        ) {
          return response(payments)
        }

        throw new Error(`Unexpected URL: ${url}`)
      },
    )

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1002)
    await openPaymentForm(wrapper)

    await wrapper
      .find('#paymentDate')
      .setValue('2026-09-03')

    await wrapper
      .find('#paymentAmount')
      .setValue('300')

    await wrapper
      .find('form.payment-form')
      .trigger('submit')

    await flushPromises()

    expect(wrapper.find('.payment-form').exists()).toBe(true)
    expect(wrapper.find('.payment-result').exists()).toBe(true)

    expect(wrapper.find('.payment-result').text()).toContain(
      'FAIL',
    )

    expect(wrapper.find('.payment-result').text()).toContain(
      '-20039',
    )

    expect(wrapper.find('.payment-result').text()).toContain(
      'Payment amount exceeds outstanding debt',
    )
  })

  it('closes payment form and reloads invoice data after successful payment', async () => {
    const updatedInvoice = {
      ...unpaidInvoice,
      debtAmount: 225,
    }

    const updatedPayments = [
      {
        paymentId: 502,
        invoiceId: 1002,
        paymentDate: '2026-09-03',
        paymentAmount: 25,
      },
    ]

    let paymentAdded = false

    const fetchMock = vi.fn().mockImplementation(
      (url: string, options?: RequestInit) => {
        if (
          url === '/api/task3/payments' &&
          options?.method === 'POST'
        ) {
          paymentAdded = true

          return response({
            statusCode: 'OK',
            errorCode: null,
            message: 'Payment successfully added',
          })
        }

        if (
          url === '/api/task3/invoices?invoiceId=1002'
        ) {
          return response([
            paymentAdded
              ? updatedInvoice
              : unpaidInvoice,
          ])
        }

        if (
          url === '/api/task3/payments?invoiceId=1002'
        ) {
          return response(
            paymentAdded
              ? updatedPayments
              : [],
          )
        }

        if (
          url.startsWith('/api/task3/invoices')
        ) {
          return response(invoices)
        }

        if (
          url.startsWith('/api/task3/payments')
        ) {
          return response(payments)
        }

        throw new Error(`Unexpected URL: ${url}`)
      },
    )

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mountView()

    await flushPromises()

    await searchInvoice(wrapper, 1002)
    await openPaymentForm(wrapper)

    await wrapper
      .find('#paymentDate')
      .setValue('2026-09-03')

    await wrapper
      .find('#paymentAmount')
      .setValue('25')

    await wrapper
      .find('form.payment-form')
      .trigger('submit')

    await flushPromises()

    expect(wrapper.find('.payment-form').exists()).toBe(false)

    expect(wrapper.find('.success-message').text()).toContain(
      'Payment successfully added',
    )

    expect(wrapper.text()).toContain('225.00')

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/invoices?invoiceId=1002',
    )

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task3/payments?invoiceId=1002',
    )

    expect(
      wrapper.find('.payments-section').text(),
    ).toContain('25.00')
  })
})
