import React from 'react'
import { render, waitFor, screen } from 'setupTests'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import DashboardTitle from '../DashboardTitle'

const mockedGetDashboardData = jest.fn()

const doRender = (
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
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Your dashboard')
      expect(container).toHaveTextContent('Mar 16')
    })
  })

  it('calls getDashboardData only once when filtering by month', async () => {
    const { container, rerender } = doRender()

    // Check value of dropdown default option
    expect(container).toHaveTextContent('Mar 2020')
    
    // Click on the dropdown
    const select = screen.getByRole('combobox')
    await waitFor(() => { userEvent.click(select, undefined, { skipPointerEventsCheck: true }) })  

    // Find dropdown option
    const option = document.getElementsByClassName('ant-select-item-option-content')[0]
    expect(option).toHaveTextContent('Feb 2020')
    expect(option).toBeVisible 

    // Select option
    await waitFor(() => userEvent.click(option, undefined, { skipPointerEventsCheck: true }))
    
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
      },
    }
    rerender(<MemoryRouter><DashboardTitle {...updatedProps} /></MemoryRouter>)

    // Check value of the updated dropdown option
    expect(container).toHaveTextContent('Feb 2020')
  })
})
