import React from 'react'
import { shallow } from 'enzyme'
import { Login } from '../Login'

jest.mock('react-ga', () => ({
  pageview: jest.fn(),
  event: jest.fn()
}))

let wrapper

describe('<Login />', () => {
  describe('before data is loaded', () => {
    beforeAll(() => {
      wrapper = shallow(<Login />)
    })

    it('renders the Login container', () => {
      expect(wrapper.find('.login').exists()).toBe(true)
    })
  })
})
