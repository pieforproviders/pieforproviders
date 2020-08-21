import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { render } from '@testing-library/react'
import App from './App'
import './i18n'

const doRender = () => {
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
