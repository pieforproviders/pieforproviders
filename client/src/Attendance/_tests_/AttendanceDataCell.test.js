import React from 'react'
import { render } from 'setupTests'
import AttendanceDataCell from '../AttendanceDataCell'

const doRender = (
  props = { columnIndex: 0, record: {}, updateAttendanceData: () => {} }
) => {
  return render(<AttendanceDataCell {...props} />)
}

describe('<AttendanceDataCell />', () => {
  it('renders content', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('CHECK IN')
    expect(container).toHaveTextContent('CHECK OUT')
    expect(container).toHaveTextContent('Absent')
    expect(container).toHaveTextContent('Absent - Covid-related')
  })
})
