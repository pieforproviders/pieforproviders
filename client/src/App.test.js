import React from 'react'
import { render } from '@testing-library/react'
import App from './App'

import { MemoryRouter } from 'react-router-dom'
import { shallow } from 'enzyme'

// TODO: unclear why this works in Login but not in App

// import ReactGA from 'react-ga'

// jest.mock('react-ga', () => ({
//   pageview: jest.fn(),
//   event: jest.fn(),
//   initialize: jest.fn()
// }))

describe('<App />', () => {
  const wrapper = shallow(
    <MemoryRouter initialEntries={['/']} initialIndex={0}>
      <App />
    </MemoryRouter>
  )

  // it('calls ReactGA.initialize()', () => {
  //   expect(ReactGA.initialize).toBeCalled()
  // })

  it('renders the App container', () => {
    expect(wrapper.contains(<App />)).toBe(true)
  })

  it('renders dashboard link', () => {
    const { getByText } = render(<App />)
    const content = getByText(/Dashboard/i)
    expect(content).toBeInTheDocument()
  })
})
