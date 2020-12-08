import React from 'react'
import { render, screen, waitFor } from 'setupTests'
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
      expect(screen.getAllByRole('columnheader').length).toEqual(7)
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Child name')
      expect(container).toHaveTextContent('Case number')
      expect(container).toHaveTextContent('Attendance rate')
      expect(container).toHaveTextContent('Guaranteed revenue')
      expect(container).toHaveTextContent('Max. approved revenue')

      expect(window.fetch).toHaveBeenCalledTimes(1)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/case_list_for_dashboard'
      )
    })
  })
})
