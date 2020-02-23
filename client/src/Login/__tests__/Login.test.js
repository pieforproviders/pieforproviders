import React from 'react'
import { shallow } from 'enzyme'
import { Login } from '../Login'
import ReactGA from 'react-ga'

jest.mock('react-ga', () => ({
  pageview: jest.fn(),
  event: jest.fn()
}))

describe('<Login />', () => {
  const wrapper = shallow(<Login />)

  it('calls ReactGA.pageview()', () => {
    expect(ReactGA.pageview).toBeCalled()
  })

  it('calls ReactGA.event()', () => {
    expect(ReactGA.event).toBeCalled()
  })

  it('renders the Login container', () => {
    expect(wrapper.find('.login').exists()).toBe(true)
  })
})
