import React from 'react'
import { render } from '@testing-library/react'
import { GettingStarted } from '../GettingStarted'

describe('<GettingStarted />', () => {
  it('renders the GettingStarted container', () => {
    const { container } = render(<GettingStarted />)
    expect(container).toHaveTextContent('Welcome to Pie for Providers')
  })
})
