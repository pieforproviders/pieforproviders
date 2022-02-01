import React from 'react'
import dayjs from 'dayjs'
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
const date = dayjs().subtract(1, 'month')

describe('<Dashboard />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('renders the Dashboard page', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(window.fetch).toHaveBeenCalledTimes(4)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/payments?filter_date=' + date.format('YYYY-MM-DD')
      )
      expect(window.fetch.mock.calls[1][0]).toBe('/api/v1/profile')
      expect(window.fetch.mock.calls[2][0]).toBe('/api/v1/businesses')
      expect(window.fetch.mock.calls[3][0]).toBe('/api/v1/notifications')
    })
  })

  it('renders the Dashboard page when a user is in state', async () => {
    const { container } = doRender({ initialState: { user: { state: 'NE' } } })
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(window.fetch).toHaveBeenCalledTimes(4)
      console.log('window.fetch.mock.calls:', window.fetch.mock.calls)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/payments?filter_date=' + date.format('YYYY-MM-DD')
      )
      expect(window.fetch.mock.calls[1][0]).toBe(
        '/api/v1/case_list_for_dashboard'
      )
      expect(window.fetch.mock.calls[2][0]).toBe('/api/v1/businesses')
      expect(window.fetch.mock.calls[3][0]).toBe('/api/v1/notifications')
    })
  })
})
