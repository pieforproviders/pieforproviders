import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { Header } from '_shared'
import { MemoryRouter } from 'react-router-dom'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <Header />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<Header />', () => {
  it('renders the Header component with Dashboard and Attendance', () => {
    const { container } = doRender({ initialState: { user: { state: 'NE' } } })
    expect(container).toHaveTextContent('Dashboard')
    expect(container).toHaveTextContent('Attendance')

    let element = screen.getByText(/Español/)
    fireEvent.click(element)
    expect(element).toHaveTextContent(/English/)

    fireEvent.click(element)
    expect(element).toHaveTextContent(/Español/)

    let attendance_button = screen.getByText(/Attendance/)
    let dashboard_button = screen.getByText(/Dashboard/)
    fireEvent.click(attendance_button)
    expect(attendance_button.closest('div')).toHaveClass('border-primaryBlue')
    expect(dashboard_button.closest('div')).not.toHaveClass(
      'border-primaryBlue'
    )
    fireEvent.click(dashboard_button)
    expect(attendance_button.closest('div')).not.toHaveClass(
      'border-primaryBlue'
    )
    expect(dashboard_button.closest('div')).toHaveClass('border-primaryBlue')
  })

  it('renders the Header component with Dashboard and Attendance', () => {
    const { container } = doRender({ initialState: { user: { state: 'IL' } } })
    expect(container).not.toHaveTextContent('Dashboard')
    expect(container).not.toHaveTextContent('Attendance')

    let element = screen.getByText(/Español/)
    fireEvent.click(element)
    expect(element).toHaveTextContent(/English/)

    fireEvent.click(element)
    expect(element).toHaveTextContent(/Español/)
  })
})
