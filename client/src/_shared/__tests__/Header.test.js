import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { Header } from '_shared'

const doRender = () => {
  return render(<Header />)
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

    let attendance_button = screen.getByText(/Attendance/)
    let dashboard_button = screen.getByText(/Dashboard/)
    fireEvent.click(attendance_button)
    expect(attendance_button).closest('div').toHaveClass('border-primaryBlue')
    expect(dashboard_button)
      .closest('div')
      .not.toHaveClass('border-primaryBlue')
    fireEvent.click(dashboard_button)
    expect(attendance_button)
      .closest('div')
      .not.toHaveClass('border-primaryBlue')
    expect(dashboard_button).closest('div').toHaveClass('border-primaryBlue')
  })
})
