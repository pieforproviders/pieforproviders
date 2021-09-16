import React from 'react'
import { render, waitFor } from 'setupTests'
import { WeekPicker } from '../WeekPicker'

const doRender = stateOptions => {
  return render(
    <WeekPicker
      dateSelected={{ weekday: (num = 0) => ({ format: () => num }) }}
    />,
    stateOptions
  )
}

describe('<WeekPicker />', () => {
  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('0 - 6')
    })
  })
})
