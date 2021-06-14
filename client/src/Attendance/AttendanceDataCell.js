import React from 'react'
import PropTypes from 'prop-types'
// import dayjs from 'dayjs'
import { Checkbox, TimePicker } from 'antd'

export default function AttendanceDataCell({ record }) {
  const handleChange = (...args) => {
    console.log(args)
  }
  console.log(record)
  // eslint-disable-next-line no-debugger
  debugger
  return (
    <div className="flex">
      <div>
        <p>Check In</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={handleChange}
          suffixIcon={null}
        />
      </div>
      <div>
        <p>Check Out</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={handleChange}
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
  record: PropTypes.object.isRequired
}
