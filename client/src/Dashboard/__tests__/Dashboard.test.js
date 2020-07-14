import React from 'react'
import { mount } from 'enzyme'
import { Dashboard } from '../Dashboard'

// mock useHistory#push.
// can't make this global or into a helper
// possibly because it's a hook
// possibly because https://github.com/facebook/create-react-app/issues/7539
const mockHistoryReplace = jest.fn()
jest.mock('react-router-dom', () => ({
  useHistory: () => ({
    push: mockHistoryReplace
  })
}))

describe('<Dashboard />', () => {
  let wrapper
  it('renders the Dashboard container', () => {
    wrapper = mount(<Dashboard />)
    expect(wrapper.find('.dashboard').exists()).toBe(true)
  })
})
