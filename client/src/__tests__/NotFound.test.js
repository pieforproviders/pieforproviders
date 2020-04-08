import React from 'react'
import { shallow } from 'enzyme'
import NotFound from '../NotFound'

describe('<NotFound />', () => {
  const wrapper = shallow(<NotFound />)

  it('renders the NotFound container', () => {
    expect(wrapper.find('.four-oh-four').exists()).toBe(true)
  })
})
