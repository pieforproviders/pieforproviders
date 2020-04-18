import React from 'react'
import { mount, shallow } from 'enzyme'
import { MemoryRouter, Route } from 'react-router'
import { Login } from '../Login'
import ReactGA from 'react-ga'
import { v4 as uuid } from 'uuid'
import { act } from 'react-dom/test-utils'
import * as useApiModule from 'react-use-fetch-api'

jest.mock('react-ga', () => ({
  pageview: jest.fn(),
  event: jest.fn()
}))

const full_name = 'First User'
const email = 'firstuser@email.com'
const id = uuid()

let wrapper

const mockReturnValue = [
  {
    full_name: full_name,
    email: email,
    id: id
  }
]
const getSpy = jest.fn(() => Promise.resolve(mockReturnValue))
jest.spyOn(useApiModule, 'useApi').mockImplementation(() => ({
  get: getSpy
}))

describe('<Login />', () => {
  describe('before data is loaded', () => {
    beforeAll(() => {
      wrapper = shallow(<Login />)
    })

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
    beforeEach(async () => {
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
      expect(getSpy).toHaveBeenCalled()
      expect(wrapper.find('.login').text()).toContain(full_name)
      expect(wrapper.find('.login').text()).toContain(email)
    })
  })
})
