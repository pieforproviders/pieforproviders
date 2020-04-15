import React from 'react'
import { mount } from 'enzyme'
import { Dashboard } from '../Dashboard'
import { v4 as uuid } from 'uuid'
import { act } from 'react-dom/test-utils'

describe('<Dashboard />', () => {
  let wrapper
  const id = uuid()
  const full_name = 'Ron Weasley'
  const email = 'test@test.com'

  it('renders the Dashboard container', () => {
    wrapper = mount(<Dashboard />)
    expect(wrapper.find('.dashboard').exists()).toBe(true)
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
        wrapper = mount(<Dashboard />)
      })
      wrapper.update()
    })

    it('renders the data', async () => {
      expect(global.fetch).toHaveBeenCalled()
      expect(wrapper.find('.dashboard').text()).toContain(full_name)
      expect(wrapper.find('.dashboard').text()).toContain(email)
    })
  })
})
