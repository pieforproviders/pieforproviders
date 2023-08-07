import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import DashboardTable from '../DashboardTable'

const doRender = (
  props = {
    tableData: [],
    userState: '',
    setActiveKey: () => {},
    dateFilterValue: undefined
  }
) => {
  return render(
    <MemoryRouter>
      <DashboardTable {...props} />
    </MemoryRouter>
  )
}

describe('<DashboardTable />', () => {
  it('renders the DashboardTable component', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(screen.getAllByRole('columnheader').length).toEqual(7)
      expect(container).toHaveTextContent('Child')
      expect(container).not.toHaveTextContent('Case number')
      expect(container).toHaveTextContent('Attendance rate')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).not.toHaveTextContent('Estimated revenue')
      expect(container).not.toHaveTextContent('Max. approved revenue')
      expect(container).toHaveTextContent('Authorized period')
      expect(container).toHaveTextContent('Actions')
    })
  })

  it('renders the DashboardTable component for NE users', async () => {
    const { container } = doRender({
      tableData: [],
      userState: 'NE',
      setActiveKey: () => {},
      dateFilterValue: undefined
    })
    await waitFor(() => {
      expect(container).toHaveTextContent('Child')
      expect(container).toHaveTextContent('Full days')
      expect(container).toHaveTextContent(/(Hours|Partial days)/i)
      expect(container).toHaveTextContent('Max hours per week')
      expect(container).toHaveTextContent('Absences')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Estimated revenue')
      expect(container).toHaveTextContent('Family fee')
      expect(container).toHaveTextContent('Authorized period')
      expect(container).toHaveTextContent(
        /(Total hours remaining|Total partial days remaining)/i
      )
      expect(container).toHaveTextContent('Total days remaining')
      expect(container).toHaveTextContent('Actions')
    })
  })

  it('renders the DashboardTable component without weekly attended hours for NE users in prior months', async () => {
    const { container } = doRender({
      tableData: [],
      userState: 'NE',
      setActiveKey: () => {},
      dateFilterValue: {
        date: new Date().setMonth(new Date().getMonth() - 2),
        displayDate: 'string'
      }
    })
    await waitFor(() => {
      expect(container).toHaveTextContent('Child')
      expect(container).toHaveTextContent('Full days')
      expect(container).toHaveTextContent(/(Hours|Partial days)/i)
      expect(container).not.toHaveTextContent('Hours attended')
      expect(container).toHaveTextContent('Absences')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Estimated revenue')
      expect(container).toHaveTextContent('Family fee')
      expect(container).toHaveTextContent('Authorized period')
      expect(container).toHaveTextContent(
        /(Total hours remaining|Total partial days remaining)/i
      )
      expect(container).toHaveTextContent('Total days remaining')
      expect(container).toHaveTextContent('Actions')
    })
  })

  it('does not render values for inactive children', async () => {
    const { getAllByText } = doRender({
      tableData: [
        {
          active: false,
          child: {
            childName: 'Inactive Child',
            childFirstName: 'Inactive',
            childLastName: 'Child',
            cNumber: 'wewewewe',
            business: 'Fake Business'
          },
          key: 'inactive-child'
        }
      ],
      userState: 'NE',
      setActiveKey: () => {},
      dateFilterValue: undefined
    })
    await waitFor(() => {
      expect(getAllByText('-').length).toEqual(10)
    })
  })
})
