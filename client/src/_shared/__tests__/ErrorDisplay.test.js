import React from 'react'
import { render, screen } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { ErrorDisplay } from '../ErrorDisplay'

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
