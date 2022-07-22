import React from 'react'
import { render, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { Dashboard } from '../Dashboard'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <Dashboard />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<Dashboard />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('renders the Dashboard page', async () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Your dashboard')
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(4)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/payments?filter_date='
      )
      expect(window.fetch.mock.calls[1][0]).toBe('/api/v1/profile')
      expect(window.fetch.mock.calls[2][0]).toBe('/api/v1/businesses')
      expect(window.fetch.mock.calls[3][0]).toBe('/api/v1/notifications')
    })
  })

  it('renders the Dashboard page when a user is in state', async () => {
    const { container } = doRender({ initialState: { user: { state: 'NE' } } })
    expect(container).toHaveTextContent('Your dashboard')
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(4)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/payments?filter_date='
      )
      expect(window.fetch.mock.calls[1][0]).toBe(
        '/api/v1/case_list_for_dashboard'
      )
      expect(window.fetch.mock.calls[2][0]).toBe('/api/v1/businesses')
      expect(window.fetch.mock.calls[3][0]).toBe('/api/v1/notifications')
    })
  })
})
