import React from 'react'
import { render } from '@testing-library/react'
import App from './App'

import { MemoryRouter } from 'react-router-dom'
import { shallow } from 'enzyme'

// TODO: I think window.matchMedia is part of the Ant React library but it's not
// implemented in JSDOM so we have to mock it:
// https://jestjs.io/docs/en/manual-mocks#mocking-methods-which-are-not-implemented-in-jsdom
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn()
  }))
})

describe('<App />', () => {
  const wrapper = shallow(
    <MemoryRouter initialEntries={['/']} initialIndex={0}>
      <App />
    </MemoryRouter>
  )

  it('renders the App container', () => {
    expect(wrapper.contains(<App />)).toBe(true)
  })

  it('renders login form', () => {
    const { getByText } = render(<App />)
    const content = getByText(/Log In/i)
    expect(content).toBeInTheDocument()
  })
})
