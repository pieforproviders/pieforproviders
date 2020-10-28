import React from 'react'
import { render } from 'setupTests'
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
  it('renders the Dashboard page', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Your dashboard')
    expect(container).toHaveTextContent('Child name')
    expect(container).toHaveTextContent('Case number')
    expect(container).toHaveTextContent('Attendance rate')
    expect(container).toHaveTextContent('Min. revenue')
    expect(container).toHaveTextContent('Max. revenue')
  })
})
