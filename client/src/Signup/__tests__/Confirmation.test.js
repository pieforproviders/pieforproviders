import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { mount } from 'enzyme'
import Confirmation from '../Confirmation'

describe('<Confirmation />', () => {
  let wrapper
  it('renders the signup confirmation page', () => {
    wrapper = mount(
      <MemoryRouter initialEntries={['/']} initialIndex={0}>
        <Confirmation />
      </MemoryRouter>
    )
    expect(wrapper.text()).toEqual(
      expect.stringContaining('Thanks for signing up')
    )
  })
})
