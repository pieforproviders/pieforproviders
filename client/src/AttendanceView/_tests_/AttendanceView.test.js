import React from 'react'
import { render, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import dayjs from 'dayjs'
import { AttendanceView } from '../AttendanceView'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <AttendanceView />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<AttendanceView />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('makes call to /attendances', async () => {
    doRender()
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(1)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/attendances?filter_date=' + dayjs().format('YYYY-MM-DD')
      )
    })
  })

  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Screen')
    })
  })
})
