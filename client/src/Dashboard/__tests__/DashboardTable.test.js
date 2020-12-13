import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import DashboardTable from '../DashboardTable'

const doRender = () => {
  return render(<DashboardTable tableData={[]} userState={''} />)
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
})
