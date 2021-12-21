import React from 'react'
import { render } from 'setupTests'
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
