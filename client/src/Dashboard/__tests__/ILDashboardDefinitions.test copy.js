import React from 'react'
import { render } from 'setupTests'
import ILDashboardDefinitions from '../ILDashboardDefinitions'

const doRender = (props = { activeKey: 1, setActiveKey: () => {} }) => {
  return render(<ILDashboardDefinitions {...props} />)
}

describe('<DashboardDefinitions />', () => {
  it('renders IL DashboardDefinitions', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Definitions')
    expect(container).toHaveTextContent('Attendance rate')
    expect(container).toHaveTextContent('On track')
    expect(container).toHaveTextContent('At risk')
    expect(container).toHaveTextContent('Earned revenue')
    expect(container).toHaveTextContent('Authorized period')
  })
})
