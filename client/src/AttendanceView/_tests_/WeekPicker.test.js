import React from 'react'
import { render, waitFor } from 'setupTests'
import { WeekPicker } from '../WeekPicker'
import dayjs from 'dayjs'

const doRender = stateOptions => {
  return render(<WeekPicker dateSelected={dayjs()} />, stateOptions)
}

const f1 = dayjs().weekday(0)
const firstDate =
  f1.format('MMM') === 'Sep'
    ? `${f1.format('MMMM').slice(0, 4)} ${f1.format('D')}`
    : f1.format('MMM D')

const f2 = dayjs().weekday(6)
const secondDate =
  f2.format('MMM') === 'Sep'
    ? `${f2.format('MMMM').slice(0, 4)} ${f2.format('D')}`
    : f2.format('MMM D')

describe('<WeekPicker />', () => {
  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent(
        `${firstDate} - ${secondDate}, ${f2.format('YYYY')}`
      )
    })
  })
})
