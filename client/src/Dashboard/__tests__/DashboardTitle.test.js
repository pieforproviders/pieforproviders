import React from 'react'
import { render, waitFor, screen } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import DashboardTitle from '../DashboardTitle'
import { fireEvent } from '@testing-library/dom'
import { mount } from 'enzyme'

const neRender = (
  props = {
    dates: { asOf: 'Mar 16' },
    getDashboardData: () => {}
  }
) => {
  return render(
    <MemoryRouter>
      <DashboardTitle {...props} />
    </MemoryRouter>
  )
}

const ilRender = (
  props = {
    dates: { asOf: 'Mar 16' },
    userState: 'IL',
    getDashboardData: () => {}
  }
) => {
  return render(
    <MemoryRouter>
      <DashboardTitle {...props} />
    </MemoryRouter>
  )
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
  it('renders DashboardTitle', async () => {
    const { container } = neRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('renders the Dashboard page when a user is in state', async () => {
    const { container } = neRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('renders the Record new Button', async () => {
    const { container } = neRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Record new')
    })
  })

  it('renders Payment modal when add record payment is clicked', async () => {
    const { container } = ilRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
    })
    const recordNewButton = screen.getByRole('button', { name: /Record new/ })
    let paymentButton = screen.queryByRole('button', {
      name: /Payment/
    })
    expect(paymentButton).not.toBeInTheDocument()
    fireEvent.click(recordNewButton)

    await waitFor(() => {
      paymentButton = screen.getByRole('button', {
        name: /Payment/
      })
      expect(paymentButton).toBeInTheDocument()
    })

    let paymentModal = screen.queryByText(/Record a payment/)
    expect(paymentModal).not.toBeInTheDocument()
    fireEvent.click(paymentButton)

    await waitFor(() => {
      paymentModal = screen.getByText(/Record a payment/)
      expect(paymentModal).toBeInTheDocument()
    })

    let closePaymentModal = screen.getByRole('button', { name: 'Close' })
    expect(closePaymentModal).toBeInTheDocument()
    fireEvent.click(closePaymentModal)

    await waitFor(() => {
      paymentModal = screen.queryByText(/Record a payment/)
      expect(paymentModal).not.toBeInTheDocument()
  it('Payment modal should render When Add Record Payment is clicked', async () => {
    const wrapper = mountRender()
    expect(wrapper.find('#paymentModal').at(0).prop('visible')).toBeFalsy()

    await waitFor(() => {
      const recordActionButton = wrapper.find('#actionsDropdownButton').at(0)
      recordActionButton.simulate('click')
      const recordPaymentButton = wrapper.find('#recordPaymentButton').at(0)
      recordPaymentButton.simulate('click')

      expect(wrapper.find('#paymentModal').at(0).prop('visible')).toBeTruthy()

      //Clicking on X button in modal to verify modal is closed
      const closeModalButton = wrapper.find('.ant-modal-close')
      closeModalButton.simulate('click')
      expect(wrapper.find('#paymentModal').at(0).prop('visible')).toBeFalsy()
    })
  })
})
