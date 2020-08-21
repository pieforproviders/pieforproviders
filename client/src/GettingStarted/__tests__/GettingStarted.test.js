import React from 'react'
import { GettingStarted } from '../GettingStarted'
import { renderWithi18next } from 'setupTests'

describe('<GettingStarted />', () => {
  it('renders the GettingStarted container', () => {
    const { container } = renderWithi18next(<GettingStarted />)
    expect(container).toHaveTextContent('Welcome to Pie for Providers')
  })
})
