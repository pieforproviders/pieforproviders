import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { Header } from '_shared'

const doRender = () => {
  return render(
    <MemoryRouter>
      <Header />
    </MemoryRouter>
  )
}

describe('<Header />', () => {
  it('renders the Header component', () => {
    doRender()
    expect(screen.getByText(/Dashboard/)).toBeDefined()
    expect(screen.getByText(/Attendance/)).toBeDefined()

    let element = screen.getByText(/Español/)
    fireEvent.click(element)
    expect(element).toHaveTextContent(/English/)

    fireEvent.click(element)
    expect(element).toHaveTextContent(/Español/)
  })
})
