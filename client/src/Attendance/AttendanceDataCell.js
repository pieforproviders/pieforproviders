import React from 'react'
import PropTypes from 'prop-types'
// import dayjs from 'dayjs'
import { Checkbox, TimePicker } from 'antd'

export default function AttendanceDataCell({
  // eslint-disable-next-line react/prop-types
  record,
  // eslint-disable-next-line react/prop-types
  index,
  updateAttendanceData
}) {
  const handleChange = (key, ...args) => {
    console.log(args)
    updateAttendanceData({ [key]: args }, record, index)
  }

  return (
    <div className="flex">
      <div>
        <p>Check In</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={(...args) => handleChange('check_in', ...args)}
          suffixIcon={null}
        />
      </div>
      <div>
        <p>Check Out</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={(...args) => handleChange('check_out', ...args)}
          suffixIcon={null}
        />
      </div>
      <div>
        <Checkbox />
        <Checkbox />
      </div>
    </div>
  )
}

AttendanceDataCell.propTypes = {
  updateAttendanceData: PropTypes.func.isRequired
}
