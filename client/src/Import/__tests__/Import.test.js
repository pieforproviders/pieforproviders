import React from 'react'
import { shallow } from 'enzyme'
import { Import } from '../Import'

describe('<Import />', () => {
  const wrapper = shallow(<Import />)

  it('renders the Import container', () => {
    expect(wrapper.find('.import').exists()).toBe(true)
  })
})
