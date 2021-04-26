import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { Header } from '_shared'

const doRender = () => {
  return render(<Header />)
}

describe('<Header />', () => {
  it('renders the Header component', () => {
    doRender()
    expect(screen.getByText(/Pie for Providers/)).toBeDefined()

    let element = screen.getByText(/Español/)
    fireEvent.click(element)
    expect(element).toHaveTextContent(/English/)

    fireEvent.click(element)
    expect(element).toHaveTextContent(/Español/)
  })
})
