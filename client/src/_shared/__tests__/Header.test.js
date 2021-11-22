import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { Header } from '_shared'
import dayjs from 'dayjs'

const doRender = stateOptions => {
  return render(<Header />, stateOptions)
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
  })

  it('displays the user avatar with username initial', () => {
    doRender(authenticatedState)
    screen.getByRole('button', {
      name: /U/i
    })
  })

  it('displays dropdown when avatar is clicked', async () => {
    doRender(authenticatedState)
    const avatar = screen.getByRole('button', {
      name: /U/i
    })

    fireEvent.click(avatar)
    await screen.findByRole('button', { name: /my profile/i })
    await screen.findByRole('button', { name: /logout/i })
    screen.debug()
  })
})
