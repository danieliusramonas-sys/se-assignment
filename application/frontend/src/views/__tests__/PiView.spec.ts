import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'

import PiView from '../PiView.vue'

describe('PiView', () => {
  it('shows calculated PI for precision 10', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        precision: 10,
        calculatedPi: 3.1415926536,
      }),
    })

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(PiView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('#precision').setValue('10')
    await wrapper.find('form').trigger('submit')

    await flushPromises()

    expect(fetchMock).toHaveBeenCalledWith(
      '/api/task2/pi',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          precision: 10,
        }),
      },
    )

    expect(wrapper.text()).toContain('10')
    expect(wrapper.text()).toContain('3.1415926536')
  })

  it('shows validation error for precision below 1', async () => {
    const fetchMock = vi.fn()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(PiView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('#precision').setValue('0')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain(
      'Precision must be between 1 and 27',
    )

    expect(fetchMock).not.toHaveBeenCalled()
  })

  it('shows validation error for precision above 27', async () => {
    const fetchMock = vi.fn()

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(PiView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('#precision').setValue('28')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain(
      'Precision must be between 1 and 27',
    )

    expect(fetchMock).not.toHaveBeenCalled()
  })

  it('shows backend error when API request fails', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: false,
      json: async () => ({
        message: 'Internal server error',
      }),
    })

    vi.stubGlobal('fetch', fetchMock)

    const wrapper = mount(PiView, {
      global: {
        stubs: {
          RouterLink: true,
        },
      },
    })

    await wrapper.find('#precision').setValue('10')
    await wrapper.find('form').trigger('submit')

    await flushPromises()

    expect(wrapper.text()).toContain(
      'Internal server error',
    )

    expect(wrapper.find('.result').exists()).toBe(false)
  })
})
