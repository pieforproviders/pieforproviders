import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
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
    expect(container).toHaveTextContent('Add check-in time')
  })

  it('adds a second set of attendance inputs', () => {
    doRender()
    let addCheckInButton = screen.getByText(/Add check-in time/)

    expect(addCheckInButton).toBeDefined()
    fireEvent.click(addCheckInButton)
    expect(screen.getByText(/Remove check-in time/)).toBeDefined()

    let checkIns = screen.getAllByText('CHECK IN')
    let checkOuts = screen.getAllByText('CHECK OUT')
    expect(checkIns.length).toBe(2)
    expect(checkOuts.length).toBe(2)
  })
})
