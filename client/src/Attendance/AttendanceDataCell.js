import React from 'react'
import PropTypes from 'prop-types'
// import dayjs from 'dayjs'
import { Checkbox, TimePicker } from 'antd'

export default function AttendanceDataCell({ updateAttendanceData }) {
  const handleChange = (key, ...args) => {
    console.log(args)
    updateAttendanceData(...args)
  }

  return (
    <div className="flex">
      <div>
        <p>Check In</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={() => handleChange('check_in')}
          suffixIcon={null}
        />
      </div>
      <div>
        <p>Check Out</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={() => handleChange('check_out')}
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
