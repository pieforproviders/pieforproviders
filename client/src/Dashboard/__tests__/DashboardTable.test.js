import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import DashboardTable from '../DashboardTable'

const doRender = (
  props = { tableData: [], userState: '', setActiveKey: () => {} }
) => {
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
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Max. approved revenue')
    })
  })

  it('renders the DashboardTable component for NE users', async () => {
    await waitFor(() => {
      const { container } = doRender({
        tableData: [],
        userState: 'NE',
        setActiveKey: () => {}
      })
      expect(container).toHaveTextContent('Child')
      expect(container).toHaveTextContent('Full days')
      expect(container).toHaveTextContent('Hours')
      expect(container).toHaveTextContent('Hours attended')
      expect(container).toHaveTextContent('Absences')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Estimated revenue')
      expect(container).toHaveTextContent('Family fee')
    })
  })
})
