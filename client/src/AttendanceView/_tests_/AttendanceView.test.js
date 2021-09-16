import React from 'react'
import { render, waitFor } from 'setupTests'
import dayjs from 'dayjs'
import { AttendanceView } from '../AttendanceView'

const doRender = stateOptions => {
  return render(<AttendanceView />, stateOptions)
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
      // expect(container).toHaveTextContent('Attendance')
    })
  })

  // it('renders mobile content', async () => {
  //   const { container } = doRender()
  //   await waitFor(() => {
  //     global.innerWidth = 300
  //     expect(container).toHaveTextContent(
  //       'Screen size not compatibleEither your browser window is too small, or you’re on a mobile device. Please switch to a desktop or tablet to view this page.'
  //     )
  //   })
  // })
})
