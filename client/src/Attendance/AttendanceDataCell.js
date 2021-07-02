import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { Checkbox, TimePicker } from 'antd'

export default function AttendanceDataCell({
  record,
  columnIndex,
  updateAttendanceData
}) {
  const [absence, setAbsence] = useState(null)
  const [checkInSelected, setCheckInSelected] = useState(false)
  const [checkOutSelected, setCheckOutSelected] = useState(false)
  const handleChange = (update = {}, cb = () => {}) => {
    updateAttendanceData(update, record, columnIndex)
    cb()
  }

  return (
    <div className="flex m-">
      <div className="mr-4">
        <p className="font-proxima-nova-alt font-semibold mb-1">
          {'Check In'.toUpperCase()}
        </p>
        <TimePicker
          className="w-20 h-8"
          use12Hours={true}
          format={'HH:mm'}
          disabled={absence}
          onChange={(m, ds) =>
            m
              ? handleChange({ check_in: ds }, setCheckInSelected(true))
              : handleChange({ check_in: '' }, setCheckInSelected(false))
          }
          suffixIcon={null}
        />
      </div>
      <div className="mr-4">
        <p className="font-proxima-nova-alt font-semibold mb-1">
          {'Check out'.toUpperCase()}
        </p>
        <TimePicker
          className="w-20 h-8"
          use12Hours={true}
          format={'HH:mm'}
          disabled={absence}
          onChange={(m, ds) =>
            m
              ? handleChange({ check_out: ds }, setCheckOutSelected(true))
              : handleChange({ check_out: '' }, setCheckOutSelected(false))
          }
          suffixIcon={null}
        />
      </div>
      <div>
        <p>
          <Checkbox
            checked={absence === 'absence'}
            disabled={
              absence === 'covid-related' || checkInSelected || checkOutSelected
            }
            onChange={e =>
              e.target.checked
                ? handleChange({ absence: 'absence' }, setAbsence('absence'))
                : handleChange({}, setAbsence(null))
            }
          />
          <span className="ml-3">Absent</span>
        </p>
        <p className="mt-2">
          <Checkbox
            checked={absence === 'covid-related'}
            disabled={
              absence === 'absence' || checkInSelected || checkOutSelected
            }
            onChange={e =>
              e.target.checked
                ? handleChange(
                    { absence: 'covid-related' },
                    setAbsence('covid-related')
                  )
                : handleChange({}, setAbsence(null))
            }
          />
          <span className="ml-3">Absent - Covid-related</span>
        </p>
      </div>
    </div>
  )
}

AttendanceDataCell.propTypes = {
  columnIndex: PropTypes.number.isRequired,
  record: PropTypes.object.isRequired,
  updateAttendanceData: PropTypes.func.isRequired
}
