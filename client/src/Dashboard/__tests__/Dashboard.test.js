import React from 'react'
import { shallow, mount } from 'enzyme'
import { Dashboard } from '../Dashboard'
import { act } from 'react-dom/test-utils'

describe('<Dashboard />', () => {
  const wrapper = shallow(<Dashboard />)

  it('renders the Dashboard container', () => {
    expect(wrapper.find('.dashboard').exists()).toBe(true)
  })

  describe('when data is loaded', () => {
    beforeAll(() => {
      global.fetch = jest.fn()
    })

    it('renders the data', async () => {
      fetch.mockImplementation(() => {
        return Promise.resolve({
          status: 200,
          json: () => {
            return Promise.resolve([
              {
                full_name: 'User First',
                email: 'test@test.com'
              }
            ])
          }
        })
      })
      await act(async () => mount(<Dashboard />))
      // .then(expect(wrapper.find('.dashboard').text()).toContain('User First'))
      // .then(
      //   expect(wrapper.find('.dashboard').text()).toContain('test@test.com')
      // )
    })
  })
})
