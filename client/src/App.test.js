import React from 'react'
import App from './App'

import { MemoryRouter } from 'react-router-dom'
import { render } from '@testing-library/react'

const doRender = () => {
  const defaultProps = {}
  return render(
    <MemoryRouter initialEntries={['/']} initialIndex={0}>
      <App />
    </MemoryRouter>
  )
}

describe('<App />', () => {
  it('renders the Login page by default', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Sign Up')
  })
})
