import { waitFor } from '@testing-library/react'
import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
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

    // test tool tip
    fireEvent.mouseOver(screen.getByTestId('definition-tool-tip'))
    waitFor(() => {
      expect(container).toHaveTextContent('definition')
    })
  })

  it('renders a set of subStats', async () => {
    const { container } = doRender({
      summaryData: [
        [
          { title: 'title1', stat: 1, definition: 'definition1' },
          { title: 'title2', stat: 2, definition: 'definition2' }
        ]
      ]
    })

    expect(container).toHaveTextContent('title1')
    expect(container).toHaveTextContent('1')
    expect(container).toHaveTextContent('title2')
    expect(container).toHaveTextContent('2')

    // test tool tip
    fireEvent.mouseOver(screen.getAllByTestId('definition-tool-tip')[0])
    fireEvent.mouseOver(screen.getAllByTestId('definition-tool-tip')[1])
    waitFor(() => {
      expect(container).toHaveTextContent('definition1')
      expect(container).toHaveTextContent('definition2')
    })
  })
})
