import React from 'react'
import Notifications from '../Notifications'
import { render, screen, fireEvent } from 'setupTests'

describe('<Notifications />', () => {
  const messages = [
    {
      message: 'This is sample message',
      date: 'June 3, 2022'
    }
  ]

  it('renders notification messages correctly', () => {
    const { container } = render(<Notifications messages={messages} />)
    const panels = container.getElementsByClassName('ant-collapse-header')

    expect(panels.length).toBe(1)
    expect(
      screen.getByText(`NOTIFICATIONS (${messages.length})`)
    ).toBeInTheDocument()

    fireEvent.click(panels[0])

    expect(screen.getByText(messages[0].message)).toBeInTheDocument()
    expect(screen.getByText(messages[0].date)).toBeInTheDocument()
  })
})
