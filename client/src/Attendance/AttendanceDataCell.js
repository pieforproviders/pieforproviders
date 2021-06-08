import React from 'react'
import dayjs from 'dayjs'
import { Checkbox, TimePicker } from 'antd'

export default function AttendanceDataCell() {
  const handleChange = (...args) => {
    console.log(args)
  }
  return (
    <div className="flex">
      <div>
        <p>Check In</p>
        <TimePicker
          use12Hours
          defaultValue={dayjs()}
          format={'HH:mm'}
          onChange={handleChange}
        />
      </div>
      <div>
        <p>Check Out</p>
        <TimePicker
          use12Hours
          defaultValue={dayjs()}
          format={'HH:mm'}
          onChange={handleChange}
        />
      </div>
      <div>
        <Checkbox />
        <Checkbox />
      </div>
    </div>
  )
}
