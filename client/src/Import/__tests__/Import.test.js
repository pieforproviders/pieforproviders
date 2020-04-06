import React from 'react'
import { shallow } from 'enzyme'
import { Import } from '../Import'
import ReactGA from 'react-ga'

jest.mock('react-ga', () => ({
  pageview: jest.fn(),
  event: jest.fn()
}))

describe('<Import />', () => {
  const wrapper = shallow(<Import />)

  it('calls ReactGA.pageview()', () => {
    expect(ReactGA.pageview).toBeCalled()
  })

  it('calls ReactGA.event()', () => {
    expect(ReactGA.event).toBeCalled()
  })

  it('renders the Import container', () => {
    expect(wrapper.find('.login').exists()).toBe(true)
  })
})
