import React from 'react'
import { render } from 'setupTests'
import DashboardStats from '../DashboardStats'

const doRender = (
  props = {
    summaryData: [{ title: 'title', stat: 123, definition: 'definition' }]
  }
) => {
  return render(<DashboardStats {...props} />)
}

describe('<DashboardStats />', () => {
  it('renders the DashboardStats component', async () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('title')
    expect(container).toHaveTextContent('123')
    expect(container).toHaveTextContent('definition')
  })
})
