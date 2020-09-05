import React from 'react'
import { render } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { GettingStarted } from '../GettingStarted'

const doRender = () => {
  return render(
    <MemoryRouter>
      <GettingStarted />
    </MemoryRouter>
  )
}
describe('<GettingStarted />', () => {
  it('renders the GettingStarted container', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Welcome to Pie for Providers')
  })
})
