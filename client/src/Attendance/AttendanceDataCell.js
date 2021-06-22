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
  const handleChange = (key, value) => {
    updateAttendanceData({ [key]: value }, record, index)
  }

  return (
    <div className="flex">
      <div>
        <p>Check In</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={(_m, ds) => handleChange('check_in', ds)}
          suffixIcon={null}
        />
      </div>
      <div>
        <p>Check Out</p>
        <TimePicker
          use12Hours
          format={'HH:mm'}
          onChange={(_m, ds) => handleChange('check_out', ds)}
          suffixIcon={null}
        />
      </div>
      <div>
        <p>
          <Checkbox
            onChange={e =>
              e.target.checked
                ? handleChange('absense', 'absence')
                : handleChange('absense', false)
            }
          />
          Absent
        </p>
        <p>
          <Checkbox
            onChange={e =>
              e.target.checked
                ? handleChange('absense', 'covid-related')
                : handleChange('absense', false)
            }
          />
          Absent - Covid-related
        </p>
      </div>
    </div>
  )
}

AttendanceDataCell.propTypes = {
  updateAttendanceData: PropTypes.func.isRequired
}
