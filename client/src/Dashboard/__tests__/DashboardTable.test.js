import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import DashboardTable from '../DashboardTable'

const doRender = (props = { tableData: [], userState: '' }) => {
  return render(<DashboardTable {...props} />)
}

describe('<DashboardTable />', () => {
  it('renders the DashboardTable component', async () => {
    await waitFor(() => {
      const { container } = doRender()
      expect(screen.getAllByRole('columnheader').length).toEqual(7)
      expect(container).toHaveTextContent('Child name')
      expect(container).toHaveTextContent('Case number')
      expect(container).toHaveTextContent('Attendance rate')
      expect(container).toHaveTextContent('Guaranteed revenue')
      expect(container).toHaveTextContent('Max. approved revenue')
    })
  })

  it('renders the DashboardTable component for NE users', async () => {
    await waitFor(() => {
      const { container } = doRender({ tableData: [], userState: 'NE' })
      expect(container).toHaveTextContent('Child')
      expect(container).toHaveTextContent('Full days')
      expect(container).toHaveTextContent('Hours')
      expect(container).toHaveTextContent('Absences')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Estimated revenue')
      expect(container).toHaveTextContent('Transportation revenue')
    })
  })

  it('renders the attendance risk tags', async () => {
    await waitFor(() => {
      const { container } = doRender({
        tableData: [
          { key: 0, fullDays: { text: '14 of 15', tag: 'on_track' } },
          { key: 1, fullDays: { text: '14 of 15', tag: 'at_risk' } },
          { key: 2, fullDays: { text: '14 of 15', tag: 'exceeded_limit' } }
        ],
        userState: 'NE'
      })
      expect(container).toHaveTextContent('On track')
      expect(container).toHaveTextContent('At risk')
      expect(container).toHaveTextContent('Exceeded limit')
    })
  })
})
