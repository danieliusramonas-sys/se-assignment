import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'

import AgeView from '../AgeView.vue'

type AgeTestCase = {
  age: number
  statusCode: string
  errorCode: number | null
  message: string
}

const testCases: AgeTestCase[] = [
  {
    age: 0,
    statusCode: 'OK',
    errorCode: null,
    message: 'You are infant',
  },
  {
    age: 10,
    statusCode: 'OK',
    errorCode: null,
    message: 'You are schoolchild',
  },
  {
    age: 25,
    statusCode: 'OK',
    errorCode: null,
    message: 'You are adult',
  },
  {
    age: 45,
    statusCode: 'OK',
    errorCode: null,
    message: 'You are in middle-age',
  },
  {
    age: 55,
    statusCode: 'OK',
    errorCode: null,
    message: 'You are aged',
  },
  {
    age: -1,
    statusCode: 'FAIL',
    errorCode: -20002,
    message: 'Age cannot be negative',
  },
]

describe('AgeView', () => {
  it.each(testCases)(
    'shows correct result for age $age',
    async ({
      age,
      statusCode,
      errorCode,
      message,
    }) => {
      const fetchMock = vi.fn().mockResolvedValue({
        ok: true,
        text: async () =>
          JSON.stringify({
            statusCode,
            errorCode,
            message,
          }),
      })

      vi.stubGlobal('fetch', fetchMock)

      const wrapper = mount(AgeView, {
        global: {
          stubs: {
            RouterLink: true,
          },
        },
      })

      await wrapper.find('#age').setValue(age.toString())
      await wrapper.find('form').trigger('submit')

      await flushPromises()

      expect(fetchMock).toHaveBeenCalledWith(
        `/api/task1/age?age=${age}`,
      )

      expect(wrapper.text()).toContain(statusCode)
      expect(wrapper.text()).toContain(message)

      if (errorCode !== null) {
        expect(wrapper.text()).toContain(
          errorCode.toString(),
        )
      }
    },
  )

  it('shows validation error when age is empty', async () => {
    const fetchMock = vi.fn()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(AgeView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain(
      'Age must be provided',
    )

    expect(fetchMock).not.toHaveBeenCalled()
  })

  it('shows backend error when API request fails', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: false,
      text: async () =>
        JSON.stringify({
          message: 'Internal server error',
        }),
    })

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(AgeView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('#age').setValue('25')
    await wrapper.find('form').trigger('submit')

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task1/age?age=25',
    )

    expect(wrapper.text()).toContain(
      'Internal server error',
    )

    expect(wrapper.find('.result').exists()).toBe(false)
  })
})
