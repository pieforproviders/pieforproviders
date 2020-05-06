import React from 'react'
import { shallow } from 'enzyme'
import { Signup } from '../Signup'

let wrapper

describe('<Signup />', () => {
  describe('the form loads', () => {
    beforeAll(() => {
      wrapper = shallow(<Signup />)
    })

    it('renders the Signup container', () => {
      expect(wrapper.find('#layout-signup').exists()).toBe(true)
    })
  })
})
