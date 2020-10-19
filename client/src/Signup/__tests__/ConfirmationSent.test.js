import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { render } from 'setupTests'
import ConfirmationSent from '../ConfirmationSent'

describe('<ConfirmationSent />', () => {
  it('renders the signup confirmation page', () => {
    const { container } = render(
      <MemoryRouter initialEntries={['/']} initialIndex={0}>
        <ConfirmationSent userEmail="hey@hey.com" />
      </MemoryRouter>
    )
    expect(container).toHaveTextContent('Thanks for signing up')
  })
})
