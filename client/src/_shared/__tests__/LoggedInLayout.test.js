import { Button } from 'antd'
import React from 'react'
import { render } from 'setupTests'
import { LoggedInLayout } from '../LoggedInLayout'

const doRender = overrideProps => {
  const defaultProps = {}
  return render(<LoggedInLayout {...defaultProps} {...overrideProps} />)
}

describe('<LoggedInLayout />', () => {
  it('renders the LoggedInLayout wrapper', () => {
    const { container } = doRender({
      children: <Button />,
      title: ''
    })
    expect(container).toHaveTextContent('Pie for Providers')
  })
})
