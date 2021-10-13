import React from 'react'
import { render, waitFor } from 'setupTests'
import { WeekPicker } from '../WeekPicker'
import dayjs from 'dayjs'

const doRender = stateOptions => {
  return render(<WeekPicker dateSelected={dayjs()} />, stateOptions)
}

describe('<WeekPicker />', () => {
  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('0 - 6')
    })
  })
})
