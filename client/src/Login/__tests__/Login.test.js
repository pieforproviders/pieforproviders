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
  const full_name = 'First User'
  const email = 'firstuser@email.com'

  it('calls ReactGA.pageview()', () => {
    expect(ReactGA.pageview).toBeCalled()
  })

  it('calls ReactGA.event()', () => {
    expect(ReactGA.event).toBeCalled()
  })

  it('renders the Login container', () => {
    expect(wrapper.find('.login').exists()).toBe(true)
  })

  describe('when data is loaded', () => {
    beforeAll(() => {
      global.fetch = jest.fn()
      fetch.mockImplementation(() => {
        return Promise.resolve({
          status: 200,
          json: () => {
            return Promise.resolve([
              {
                full_name: full_name,
                email: email
              }
            ])
          }
        })
      })
    })

    it('renders the data', () => {
      expect(wrapper.find('.login').text()).toContain(full_name)
      expect(wrapper.find('.login').text()).toContain(email)
    })
  })
})
