import React from 'react'
import { render, fireEvent, screen } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import AttendanceDataCell from '../AttendanceDataCell'

const doRender = overrideProps => {
  const defaultProps = {
    columnIndex: 0,
    record: {},
    updateAttendanceData: () => {}
  }
  return render(
    <MemoryRouter>
      <AttendanceDataCell {...defaultProps} {...overrideProps} />
    </MemoryRouter>
  )
}

describe('<AttendanceDataCell />', () => {
  it('renders content', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('CHECK IN')
    expect(container).toHaveTextContent('CHECK OUT')
    expect(container).toHaveTextContent('Absent')
    expect(container).not.toHaveTextContent('Absent - COVID-related')
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

  it('displays the covid-related absence if the date is before July 31', () => {
    const { container } = doRender({ columnDate: '2021-06-30' })
    expect(container).toHaveTextContent('CHECK IN')
    expect(container).toHaveTextContent('CHECK OUT')
    expect(container).toHaveTextContent('Absent')
    expect(container).toHaveTextContent('Absent - COVID-related')
  })

  it('does not display the covid-related absence if the date is after July 31', () => {
    const { container } = doRender({ columnDate: '2021-10-30' })
    expect(container).toHaveTextContent('CHECK IN')
    expect(container).toHaveTextContent('CHECK OUT')
    expect(container).toHaveTextContent('Absent')
    expect(container).not.toHaveTextContent('Absent - COVID-related')
  })
})
