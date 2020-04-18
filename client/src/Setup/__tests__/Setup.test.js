import React from 'react'
import { shallow, mount } from 'enzyme'
import { Setup } from '../Setup'
import { v4 as uuid } from 'uuid'
import { act } from 'react-dom/test-utils'
import * as useApiModule from 'react-use-fetch-api'

const businessId = uuid()
const businessName = 'Happy Hearts Childcare'
// We need to wrap this in a memoryrouter for useParams to work
let wrapper

const mockReturnValue = [
  {
    id: businessId,
    name: businessName
  }
]
const getSpy = jest.fn(() => Promise.resolve(mockReturnValue))
jest.spyOn(useApiModule, 'useApi').mockImplementation(() => ({
  get: getSpy
}))

describe('<Setup />', () => {
  it('renders the Setup container', () => {
    wrapper = shallow(<Setup />)
    expect(wrapper.find('.setup').exists()).toBe(true)
  })

  describe('when data is loaded', () => {
    beforeEach(async () => {
      await act(async () => {
        wrapper = mount(<Setup />)
      })
      wrapper.update()
    })

    it('renders the data', () => {
      expect(getSpy).toHaveBeenCalled()
      expect(wrapper.find('.setup').text()).toContain(businessId)
      expect(wrapper.find('.setup').text()).toContain(businessName)
    })
  })
})
