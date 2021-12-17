import React from 'react'
import { render, screen } from 'setupTests'
import { ErrorDisplay } from '../ErrorDisplay'
import { MemoryRouter } from 'react-router-dom'

const doRender = () => {
  return render(
    <MemoryRouter>
      <ErrorDisplay />
    </MemoryRouter>
  )
}

describe('<ErrorDisplay />', () => {
  it('renders the ErrorDisplay component', () => {
    doRender()
    expect(screen.getByText(/Oops!/)).toBeDefined()
    expect(screen.getByText(/Go back/)).not.toHaveAttribute('disabled')
  })
})
