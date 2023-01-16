import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { render } from 'setupTests'
import { Signup } from '../Signup'

describe('<Signup />', () => {
  it('renders the signup page', () => {
    const { container } = render(
      <MemoryRouter>
        <Signup />
      </MemoryRouter>
    )
    expect(container).toHaveTextContent('Welcome to Pie for Providers')
    expect(container).toHaveTextContent(
      'Sign up today to claim more childcare subsidy funding'
    )
    expect(container).toHaveTextContent(
      'What are you hoping to get from using Pie for Providers?'
    )
    expect(container).toHaveTextContent('How did you hear about us?')
  })
})
