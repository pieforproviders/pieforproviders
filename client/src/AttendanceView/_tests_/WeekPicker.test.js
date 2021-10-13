import React from 'react'
import { render, waitFor } from 'setupTests'
import { WeekPicker } from '../WeekPicker'
import dayjs from 'dayjs'
import weekday from 'dayjs/plugin/weekday'

dayjs.extend(weekday)
const day = dayjs()

const doRender = stateOptions => {
  return render(<WeekPicker dateSelected={day} />, stateOptions)
}

describe('<WeekPicker />', () => {
  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent(
        `${day.weekday(0).format('MMM D')} - ${day
          .weekday(6)
          .format('MMM D, YYYY')}`
      )
    })
  })
})
