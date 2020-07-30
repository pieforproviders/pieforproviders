import React from 'react'
import { render } from '@testing-library/react'
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
    expect(container).toHaveTextContent('This is the dashboard')
  })
})
