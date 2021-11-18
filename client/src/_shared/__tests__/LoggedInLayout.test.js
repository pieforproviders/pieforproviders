import { Button } from 'antd'
import React from 'react'
import { MemoryRouter } from 'react-router-dom'
import { render } from 'setupTests'
import { LoggedInLayout } from '../LoggedInLayout'

const doRender = overrideProps => {
  const defaultProps = {}
  return render(
    <MemoryRouter>
      <LoggedInLayout {...defaultProps} {...overrideProps} />
    </MemoryRouter>
  )
}

describe('<LoggedInLayout />', () => {
  it('renders the LoggedInLayout wrapper', () => {
    const { container } = doRender({
      children: <Button />,
      title: ''
    })
    expect(container).toHaveTextContent('Attendance')
    expect(container).toHaveTextContent('Dashboard')
  })
})
