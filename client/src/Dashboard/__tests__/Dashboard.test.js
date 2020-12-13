import React from 'react'
import { render, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { Dashboard } from '../Dashboard'

const doRender = () => {
  return render(
    <MemoryRouter>
      <Dashboard />
    </MemoryRouter>
  )
}

describe('<Dashboard />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('renders the Dashboard page', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(window.fetch).toHaveBeenCalledTimes(2)
      expect(window.fetch.mock.calls[0][0]).toBe('/api/v1/profile')
      expect(window.fetch.mock.calls[1][0]).toBe(
        '/api/v1/case_list_for_dashboard'
      )
    })
  })
})
