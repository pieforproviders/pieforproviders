import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { render } from '@testing-library/react'
import Confirmation from '../Confirmation'

describe('<Confirmation />', () => {
  it('renders the signup confirmation page', () => {
    const { container } = render(
      <MemoryRouter initialEntries={['/']} initialIndex={0}>
        <Confirmation />
      </MemoryRouter>
    )
    expect(container).toHaveTextContent('Thanks for signing up')
  })
})
