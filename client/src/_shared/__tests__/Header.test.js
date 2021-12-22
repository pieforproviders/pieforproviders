/* eslint-disable no-unused-vars */
import React from 'react'
import { render, fireEvent, screen, within } from 'setupTests'
import { createMemoryHistory } from 'history'
import { Header } from '_shared'
import { MemoryRouter } from 'react-router-dom'
import dayjs from 'dayjs'
import { Router } from 'react-router-dom'

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
    expect(
      screen.getByRole('button', {
        name: /U/i
      })
    ).toBeInTheDocument()
  })

  it('displays dropdown when avatar is clicked', async () => {
    doRender(authenticatedState)
    const avatar = screen.getByRole('button', {
      name: /U/i
    })

    fireEvent.click(avatar)
    await screen.findByRole('button', { name: /my profile/i })
    await screen.findByRole('button', { name: /logout/i })
  })

  it('does not display underline when My Profile is not selected', async () => {
    doRender(authenticatedState)

    const avatar = screen.getByRole('button', {
      name: /U/i
    })

    fireEvent.click(avatar)
    const profileButton = await screen.findByRole('button', {
      name: /my profile/i
    })
    const profileText = within(profileButton).getByText(/my profile/i)
    expect(profileText).not.toHaveClass('underline')
  })

  it('displays underline when My Profile is selected', async () => {
    doRender(authenticatedState, '/profile')

    const avatar = screen.getByRole('button', {
      name: /U/i
    })

    fireEvent.click(avatar)
    const profileButton = await screen.findByRole('button', {
      name: /my profile/i
    })
    const profileText = within(profileButton).getByText(/my profile/i)
    fireEvent.click(profileText)
    expect(profileText).toHaveClass('underline')
    fireEvent.click(avatar)
    expect(profileButton).toBeInTheDocument()
    expect(await profileText).toHaveClass('underline')
  })
})
