import React from 'react'
import { render } from 'setupTests'
import App from './App'
import './i18n'

const doRender = () => {
  return render(<App />)
}

describe('<App />', () => {
  it('renders the Login page by default', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Sign Up')
  })
})
