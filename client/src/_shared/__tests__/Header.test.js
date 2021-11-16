import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { Header } from '_shared'
import { MemoryRouter } from 'react-router-dom'
import dayjs from 'dayjs'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <Header />
    </MemoryRouter>,
    stateOptions
  )
}

const authenticatedState = {
  initialState: {
    auth: {
      token: 'whatever',
      expiration: dayjs().add('2', 'days').format()
    },
    user: { greeting_name: 'User' }
  }
}

describe('<Header />', () => {
  it('renders the Header component', () => {
    doRender()
    expect(screen.getByText(/Dashboard/)).toBeDefined()
    expect(screen.getByText(/Attendance/)).toBeDefined()

    const element = screen.getByText(/Español/)
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

  it('displays the user avatar with username initial', () => {
    doRender(authenticatedState)
    const avatar = screen.getByTestId('avatar')

    expect(avatar).toHaveTextContent('U')
  })

  it('displays dropdown when avatar is hovered over', async () => {
    doRender(authenticatedState)
    const avatar = screen.getByTestId('avatar')

    fireEvent.mouseOver(avatar)
    await screen.findByRole('button', { name: /my profile/i })
    await screen.findByRole('button', { name: /logout/i })
  })
})
