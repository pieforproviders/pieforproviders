import React from 'react'
import { render, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import DashboardTitle from '../DashboardTitle'

const doRender = (
  props = {
    dates: { asOf: 'Mar 16' }, userState: 'IL', getDashboardData: () => {}
  }
) => {
  return render(<DashboardTitle {...props} />)
}

describe('<DashboardTitle />', () => {
  // beforeEach(() => jest.spyOn(window, 'fetch'))

  // afterEach(() => window.fetch.mockRestore())

  it('renders DashboardTitle', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('renders the Dashboard page when a user is in state', async () => {
    const { container } = doRender({ dates: { asOf: 'Mar 16' }, userState: 'NE', getDashboardData: () => {}})
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })
})