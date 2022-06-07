import React from 'react'
import { render, waitFor, screen } from 'setupTests'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import DashboardTitle from '../DashboardTitle'
import { fireEvent } from '@testing-library/dom'

const mockedGetDashboardData = jest.fn()

const neRender = (
  props = {
    dates: {
      asOf: 'Mar 16',
      dateFilterValue: {
        displayDate: '2020-03-16',
        date: 'Mar 2020'
      },
      dateFilterMonths: [
        {
          displayDate: '2020-02-16',
          date: 'Feb 2020'
        },
        {
          displayDate: '2020-01-16',
          date: 'Jan 2020'
        }
      ]
    },
    getDashboardData: mockedGetDashboardData,
    makeMonth: () => {},
    setDates: () => {}
  }
) => {
  return render(
    <MemoryRouter>
      <DashboardTitle {...props} />
    </MemoryRouter>
  )
}

// const ilRender = (
//   props = {
//     dates: { asOf: 'Mar 16' },
//     userState: 'IL',
//     getDashboardData: () => {}
//   }
// ) => {
//   return render(
//     <MemoryRouter>
//       <DashboardTitle {...props} />
//     </MemoryRouter>
//   )
// }

describe('<DashboardTitle />', () => {
  beforeEach(() => {
    jest.spyOn(window, 'fetch').mockImplementation(jest.fn())
    window.fetch.mockResolvedValueOnce({})
  })

  afterEach(() => window.fetch.mockRestore())

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

  it('calls getDashboardData only once when filtering by month', async () => {
    const { container, rerender } = neRender()

    // Check value of dropdown default option
    expect(container).toHaveTextContent('Mar 2020')

    // Click on the dropdown
    const select = screen.getByRole('combobox')
    await waitFor(() => {
      userEvent.click(select, undefined, { skipPointerEventsCheck: true })
    })

    // Find dropdown option
    const option = document.getElementsByClassName(
      'ant-select-item-option-content'
    )[0]
    expect(option).toHaveTextContent('Feb 2020')

    // Select option
    await waitFor(() =>
      userEvent.click(option, undefined, { skipPointerEventsCheck: true })
    )

    // Check if getDashboardData was called
    expect(mockedGetDashboardData).toHaveBeenCalledTimes(1)

    // Rerender component with updated dates
    const updatedProps = {
      dates: {
        asOf: 'Feb 16',
        dateFilterValue: {
          displayDate: '2020-02-16',
          date: 'Feb 2020'
        },
        dateFilterMonths: [
          {
            displayDate: '2020-03-16',
            date: 'Mar 2020'
          },
          {
            displayDate: '2020-01-16',
            date: 'Jan 2020'
          }
        ]
      }
    }
    rerender(
      <MemoryRouter>
        <DashboardTitle {...updatedProps} />
      </MemoryRouter>
    )

    // Check value of the updated dropdown option
    expect(container).toHaveTextContent('Feb 2020')
  })

  it('renders the Record new Button', async () => {
    const { container } = neRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Record new')
    })
  })

  it('renders Payment modal when add record payment is clicked', async () => {
    const { container } = neRender()
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
    })
  })
})
