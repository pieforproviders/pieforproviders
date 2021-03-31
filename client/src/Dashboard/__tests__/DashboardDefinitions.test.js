import React from 'react'
import { render } from 'setupTests'
import DashboardDefinitions from '../DashboardDefinitions'

const doRender = (props = { activeKey: 1, setActiveKey: () => {} }) => {
  return render(<DashboardDefinitions {...props} />)
}

describe('<DashboardDefinitions />', () => {
  it('renders the DashboardDefinition', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Definitions')
    expect(container).toHaveTextContent('Attendance')
    expect(container).toHaveTextContent('Exceeded limit')
    expect(container).toHaveTextContent('On track')
    expect(container).toHaveTextContent('At risk')
    expect(container).toHaveTextContent('Ahead of schedule')
    expect(container).toHaveTextContent('Full days')
    expect(container).toHaveTextContent('Hours')
    expect(container).toHaveTextContent('Hours attended')
    expect(container).toHaveTextContent('Absences')
    expect(container).toHaveTextContent('Revenue')
    expect(container).toHaveTextContent('Earned revenue')
    expect(container).toHaveTextContent('Estimated revenue')
    expect(container).toHaveTextContent('Family fee')
    expect(container).toHaveTextContent('Back to top')
  })
})
