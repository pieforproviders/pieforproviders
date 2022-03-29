import React from 'react'
import { screen, render } from 'setupTests'
import Profile from '../../Profile'

const testUser = {
  businesses: [
    {
      accredited: true,
      county: 'Douglas',
      license_type: 'family_child_care_home_i',
      name: 'Nebraska Home Child Care',
      qris_rating: 'Test',
      zipcode: '68123'
    }
  ],
  email: 'nebraska@test.com',
  full_name: 'Nebraska Provider',
  greeting_name: 'Candice',
  language: 'en',
  phone_number: 1111111111
}

const initialState = {
  initialState: {
    user: testUser
  }
}

// Allow for media queries to be used
beforeEach(() => {
  window.matchMedia = jest.fn().mockImplementation(query => ({
    matches: query === '(max-width: 575px)',
    media: '',
    addListener: () => {},
    removeListener: () => {}
  }))
})

describe('<Profile />', () => {
  it('displays user properties', () => {
    render(<Profile />, initialState)

    screen.getByText(/Nebraska Provider/)
    screen.getByText(/English/)
    screen.getByText(/1111111111/)
    screen.getByText(/nebraska@test.com/)
  })

  it('displays business properties', () => {
    render(<Profile />, initialState)

    screen.getByText(/Yes/)
    screen.getByText(/Douglas, 68123/i)
    screen.getByText(/family_child_care_home_i/)
    screen.getByText(/Nebraska Home Child Care/)
    screen.getByText(/Test/)
    screen.getByText(/1 child care business/)
  })

  it('displays multi business field', () => {
    render(<Profile />, initialState)

    screen.getByText(/Yes/)
    screen.getByText(/Douglas, 68123/)
    screen.getByText(/family_child_care_home_i/)
    screen.getByText(/Nebraska Home Child Care/)
    screen.getByText(/Test/)
    screen.getByText(/1 child care business/)
  })
})
