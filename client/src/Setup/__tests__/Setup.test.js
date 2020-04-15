import React from 'react'
import { mount } from 'enzyme'
import { Setup } from '../Setup'
import { MemoryRouter, Route } from 'react-router'
import { v4 as uuid } from 'uuid'
import { act } from 'react-dom/test-utils'

describe('<Setup />', () => {
  const businessId = uuid()
  const businessName = 'Happy Hearts Childcare'
  // We need to wrap this in a memoryrouter for useParams to work
  let wrapper

  it('renders the Setup container', () => {
    wrapper = mount(
      <MemoryRouter initialEntries={[`/${businessId}/setup`]}>
        <Route path="/:id/setup">
          <Setup />
        </Route>
      </MemoryRouter>
    )
    expect(wrapper.find('.setup').exists()).toBe(true)
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
                id: businessId,
                name: businessName
              }
            ])
          }
        })
      })
      await act(async () => {
        wrapper = mount(
          <MemoryRouter initialEntries={[`/setup`]}>
            <Route path="/setup">
              <Setup />
            </Route>
          </MemoryRouter>
        )
      })
      wrapper.update()
    })

    it('renders the data', () => {
      expect(global.fetch).toHaveBeenCalled()
      expect(wrapper.find('.setup').text()).toContain(businessId)
      expect(wrapper.find('.setup').text()).toContain(businessName)
    })
  })
})
