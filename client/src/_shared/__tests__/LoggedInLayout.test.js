import { Button } from 'antd'
import React from 'react'
import { render } from 'setupTests'
import { LoggedInLayout } from '../LoggedInLayout'
import { MemoryRouter } from 'react-router-dom'

const doRender = (overrideProps, stateOptions) => {
  const defaultProps = {}
  return render(
    <MemoryRouter>
      <LoggedInLayout {...defaultProps} {...overrideProps} />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<LoggedInLayout />', () => {
  it('renders the LoggedInLayout wrapper', () => {
    const { container } = doRender(
      {
        children: <Button />,
        title: ''
      },
      { initialState: { user: { state: 'NE' } } }
    )
    expect(container).toHaveTextContent('Attendance')
    expect(container).toHaveTextContent('Dashboard')
  })

  it('renders the LoggedInLayout wrapper without header nav buttons', () => {
    const { container } = doRender(
      {
        children: <Button />,
        title: ''
      },
      { initialState: { user: { state: 'IL' } } }
    )
    expect(container).not.toHaveTextContent('Attendance')
    expect(container).not.toHaveTextContent('Dashboard')
  })
})
