import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { Checkbox, TimePicker } from 'antd'
import { useTranslation } from 'react-i18next'
import '_assets/styles/checkbox-overrides.css'

export default function AttendanceDataCell({
  record,
  columnIndex,
  columnDate,
  updateAttendanceData
}) {
  const { t } = useTranslation()
  const [absence, setAbsence] = useState(null)
  const [checkInSelected, setCheckInSelected] = useState(false)
  const [checkOutSelected, setCheckOutSelected] = useState(false)
  const handleChange = (update = {}, callback = () => {}) => {
    updateAttendanceData(update, record, columnIndex)
    callback()
  }

  return (
    <div className="flex m-">
      <div className="mr-4">
        <p className="mb-1 font-semibold font-proxima-nova-alt">
          {t('checkIn').toUpperCase()}
        </p>
        <TimePicker
          className="w-20 h-8"
          style={{
            border: '1px solid #D9D9D9'
          }}
          use12Hours={true}
          format="h:mm a"
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
        <p className="mb-1 font-semibold font-proxima-nova-alt">
          {t('checkOut').toUpperCase()}
        </p>
        <TimePicker
          className="w-20 h-8"
          style={{
            border: '1px solid #D9D9D9'
          }}
          use12Hours={true}
          format="h:mm a"
          disabled={absence}
          onChange={(dateObject, dateString) =>
            dateObject
              ? handleChange(
                  { check_out: dateString },
                  setCheckOutSelected(true)
                )
              : handleChange({ check_out: '' }, setCheckOutSelected(false))
          }
          suffixIcon={null}
        />
      </div>
      <div>
        <p>
          <Checkbox
            className="absence"
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
          <span className="ml-3">{t('absent')}</span>
        </p>
        {columnDate && new Date(columnDate) <= new Date('2021-07-31') && (
          <p className="mt-2">
            <Checkbox
              className="absence"
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
            <span className="ml-3">
              {t('absent') + ' - ' + t('covidRelated')}
            </span>
          </p>
        )}
      </div>
    </div>
  )
}

AttendanceDataCell.propTypes = {
  columnDate: PropTypes.string,
  columnIndex: PropTypes.number.isRequired,
  record: PropTypes.object.isRequired,
  updateAttendanceData: PropTypes.func.isRequired
}
