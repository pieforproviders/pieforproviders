import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import DashboardTable from '../DashboardTable'

const doRender = (
  props = { tableData: [], userState: '', setActiveKey: () => {} }
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
      expect(screen.getAllByRole('columnheader').length).toEqual(8)
      expect(container).toHaveTextContent('Child name')
      expect(container).toHaveTextContent('Case number')
      expect(container).toHaveTextContent('Attendance rate')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Max. approved revenue')
      expect(container).toHaveTextContent('Actions')
    })
  })

  it('renders the DashboardTable component for NE users', async () => {
    const { container } = doRender({
      tableData: [],
      userState: 'NE',
      setActiveKey: () => {}
    })
    await waitFor(() => {
      expect(container).toHaveTextContent('Child')
      expect(container).toHaveTextContent('Full days')
      expect(container).toHaveTextContent('Hours')
      expect(container).toHaveTextContent('Hours attended')
      expect(container).toHaveTextContent('Absences')
      expect(container).toHaveTextContent('Earned revenue')
      expect(container).toHaveTextContent('Estimated revenue')
      expect(container).toHaveTextContent('Family fee')
      expect(container).toHaveTextContent('Actions')
    })
  })
})
