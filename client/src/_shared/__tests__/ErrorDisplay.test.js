import React from 'react'
import { render, screen } from 'setupTests'
import { ErrorDisplay } from '../ErrorDisplay'

const doRender = () => {
  return render(<ErrorDisplay />)
}

describe('<ErrorDisplay />', () => {
  it('renders the ErrorDisplay component', () => {
    doRender()
    expect(screen.getByText(/Oops!/)).toBeDefined()
    expect(screen.getByText(/Go back/)).not.toHaveAttribute('disabled')
  })
})
