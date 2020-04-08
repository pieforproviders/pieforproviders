import React from 'react'
import { mount } from 'enzyme'
import { Setup } from '../Setup'
import { MemoryRouter, Route } from 'react-router'
import { v4 as uuid } from 'uuid'

describe('<Setup />', () => {
  const businessId = uuid()
  // We need to wrap this in a memoryrouter for useParams to work
  const wrapper = mount(
    <MemoryRouter initialEntries={[`/${businessId}/setup`]}>
      <Route path="/:id/setup">
        <Setup />
      </Route>
    </MemoryRouter>
  )

  it('renders the Setup container', () => {
    expect(wrapper.find('.setup').exists()).toBe(true)
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
                id: businessId
              }
            ])
          }
        })
      })
    })

    it('renders the data', () => {
      expect(wrapper.find('.setup').text()).toContain(businessId)
    })
  })
})
