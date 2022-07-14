import React from 'react'
import Notifications from '../Notifications'
import { render, screen } from 'setupTests'

describe('<Notifications />', () => {
  const messages = [
    {
      first_name: 'Jane',
      last_name: 'Queen',
      effective_on: 'Mon, 06 Jun 2022 18:01:18.814736000 UTC +00:00',
      expiration_date: 'Mon, 01 Jun 2022 18:01:18.814736000 UTC +00:00'
    }
  ]

  it('renders notification messages correctly', () => {
    const { container } = render(<Notifications messages={messages} />)
    const panels = container.getElementsByClassName('ant-list-items')

    expect(panels.length).toBe(1)
    expect(
      screen.getByText(`NOTIFICATIONS (${messages.length})`)
    ).toBeInTheDocument()
  })

  it('shows modal option', () => {
    render(<Notifications messages={[...messages, ...messages, ...messages]} />)

    expect(screen.getByText(`NOTIFICATIONS (3)`)).toBeInTheDocument()
    expect(screen.getByText(`See all notifications here`)).toBeInTheDocument()
  })
})
