import React from 'react'
import { mount } from 'enzyme'
import { Dashboard } from '../Dashboard'

describe('<Dashboard />', () => {
  let wrapper
  it('renders the Dashboard container', () => {
    wrapper = mount(<Dashboard />)
    expect(wrapper.find('.dashboard').exists()).toBe(true)
  })
})
