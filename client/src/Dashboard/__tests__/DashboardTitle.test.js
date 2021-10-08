import React from 'react'
import { render, waitFor } from 'setupTests'
import DashboardTitle from '../DashboardTitle'
import { mount } from 'enzyme'

const doRender = (
  props = {
    dates: { asOf: 'Mar 16' },
    userState: 'IL',
    getDashboardData: () => {}
  }
) => {
  return render(<DashboardTitle {...props} />)
}

const mountRender = (
  props = {
    dates: { asOf: 'Mar 16' },
    userState: 'IL',
    getDashboardData: () => {}
  }
) => {
  return mount(<DashboardTitle {...props} />)
}

describe('<DashboardTitle />', () => {
  // beforeEach(() => jest.spyOn(window, 'fetch'))

  // afterEach(() => window.fetch.mockRestore())

  it('renders DashboardTitle', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('renders the Dashboard page when a user is in state', async () => {
    const { container } = doRender({
      dates: { asOf: 'Mar 16' },
      userState: 'NE',
      getDashboardData: () => {}
    })
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('renders shows the Record new Button', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Record new')
    })
  })

  it('Payment modal should render When Add Record Payment is clicked', async () => {
    const wrapper = mountRender()
    const paymentModal = wrapper.find('#paymentModal').at(0)
    expect(paymentModal.prop('visible')).toBeFalsy()

    const recordActionButton = wrapper.find('#actionsDropdownButton').at(0)
    recordActionButton.simulate('click')
    const recordPaymentButton = wrapper.find('#recordPaymentButton').at(0)
    await recordPaymentButton.simulate('click')

    expect(wrapper.find('#paymentModal').at(1).prop('visible')).toBeTruthy()
  })
})
