import React from 'react'
import { mount } from 'enzyme'
import { MemoryRouter, Route } from 'react-router'
import { Login } from '../Login'
import ReactGA from 'react-ga'
import { v4 as uuid } from 'uuid'
import { act } from 'react-dom/test-utils'

jest.mock('react-ga', () => ({
  pageview: jest.fn(),
  event: jest.fn()
}))

describe('<Login />', () => {
  let wrapper
  const full_name = 'First User'
  const email = 'firstuser@email.com'
  const id = uuid()

  describe('before data is loaded', () => {
    wrapper = mount(
      <MemoryRouter initialEntries={[`/login`]}>
        <Route path="/login">
          <Login />
        </Route>
      </MemoryRouter>
    )
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

  describe('when data is loaded', () => {
    beforeAll(async () => {
      global.fetch = jest.fn()
      fetch.mockImplementation(() => {
        return Promise.resolve({
          status: 200,
          json: () => {
            return Promise.resolve([
              {
                full_name: full_name,
                email: email,
                id: id
              }
            ])
          }
        })
      })
      await act(async () => {
        wrapper = mount(
          <MemoryRouter initialEntries={[`/login`]}>
            <Route path="/login">
              <Login />
            </Route>
          </MemoryRouter>
        )
      })
      wrapper.update()
    })

    it('renders the data', () => {
      wrapper.update()
      expect(wrapper.find('.login').text()).toContain(full_name)
      expect(wrapper.find('.login').text()).toContain(email)
    })
  })
})
