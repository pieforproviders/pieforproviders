import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { Button, Checkbox, TimePicker } from 'antd'
import { CloseOutlined, PlusOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/checkbox-overrides.css'

export default function AttendanceDataCell({
  record,
  columnIndex,
  updateAttendanceData
}) {
  const { t } = useTranslation()
  const [absence, setAbsence] = useState(null)
  const [checkInSelected, setCheckInSelected] = useState(false)
  const [checkOutSelected, setCheckOutSelected] = useState(false)
  const [showSecondCheckIn, setShowSecondCheckIn] = useState(false)
  const handleChange = options => {
    const { update = {}, callback = () => {}, secondCheckIn = false } = options
    updateAttendanceData({ update, record, columnIndex, secondCheckIn })
    callback()
  }

  return (
    <div className="flex flex-col m-">
      <div className="flex flex-row">
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
                ? handleChange({
                    update: { check_in: ds },
                    callback: setCheckInSelected(true)
                  })
                : handleChange({
                    update: { check_in: '' },
                    callback: setCheckInSelected(false)
                  })
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
                ? handleChange({
                    update: { check_out: dateString },
                    callback: setCheckOutSelected(true)
                  })
                : handleChange({
                    updates: { check_out: '' },
                    callback: setCheckOutSelected(false)
                  })
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
                absence === 'covid-related' ||
                checkInSelected ||
                checkOutSelected
              }
              onChange={e =>
                e.target.checked
                  ? handleChange({
                      update: { absence: 'absence' },
                      callback: () => {
                        setShowSecondCheckIn(false)
                        setAbsence('absence')
                      }
                    })
                  : handleChange({ callback: setAbsence(null) })
              }
            />
            <span className="ml-3">{t('absent')}</span>
          </p>
          <p className="mt-2">
            <Checkbox
              className="absence"
              checked={absence === 'covid-related'}
              disabled={
                absence === 'absence' || checkInSelected || checkOutSelected
              }
              onChange={e =>
                e.target.checked
                  ? handleChange({
                      update: { absence: 'covid-related' },
                      callback: () => {
                        setShowSecondCheckIn(false)
                        setAbsence('covid-related')
                      }
                    })
                  : handleChange({ callback: setAbsence(null) })
              }
            />
            <span className="ml-3">
              {t('absent') + ' - ' + t('covidRelated')}
            </span>
          </p>
        </div>
      </div>
      {showSecondCheckIn ? (
        <div className="flex flex-row mt-4">
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
              onChange={(m, ds) =>
                m
                  ? handleChange({
                      update: { check_in: ds },
                      secondCheckIn: true
                    })
                  : handleChange({
                      update: { check_in: '' },
                      secondCheckIn: true
                    })
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
              onChange={(dateObject, dateString) =>
                dateObject
                  ? handleChange({
                      update: { check_out: dateString },
                      secondCheckIn: true
                    })
                  : handleChange({
                      update: { check_out: '' },
                      secondCheckIn: true
                    })
              }
              suffixIcon={null}
            />
          </div>
          <div className="flex items-center">
            <Button
              type="text"
              className="flex font-semibold font-proxima-nova -ml-4"
              onClick={() => {
                handleChange({ secondCheckIn: true })
                setShowSecondCheckIn(false)
              }}
            >
              <CloseOutlined className="font-semibold text-red1" />
              <p className="text-red1 ml-1">{t('removeCheckInTime')}</p>
            </Button>
          </div>
        </div>
      ) : (
        <div className="mt-4">
          <Button
            disabled={absence}
            type="text"
            className="flex font-semibold font-proxima-nova -ml-4"
            onClick={() => setShowSecondCheckIn(true)}
          >
            <PlusOutlined className="font-semibold text-primaryBlue" />
            <p className="ml-2 text-primaryBlue">{t('addCheckInTime')}</p>
          </Button>
        </div>
      )}
    </div>
  )
}

AttendanceDataCell.propTypes = {
  columnIndex: PropTypes.number.isRequired,
  record: PropTypes.object.isRequired,
  updateAttendanceData: PropTypes.func.isRequired
}
