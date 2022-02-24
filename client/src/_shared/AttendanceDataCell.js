import React, { useEffect, useState } from 'react'
import PropTypes, { object } from 'prop-types'
import { Button, Checkbox } from 'antd'
import dayjs from 'dayjs'
import { TimePicker } from '../_shared'
import { CloseOutlined, PlusOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/checkbox-overrides.css'

export default function AttendanceDataCell({
  record = {},
  columnIndex,
  columnDate,
  defaultValues = [],
  updateAttendanceData = () => {}
}) {
  const { t } = useTranslation()
  const secondCheckInExists = () =>
    Object.keys(defaultValues[1] || {}).length > 0

  const createTimePickerValues = () => {
    const setTimeValue = value =>
      value ? dayjs(value, 'YYYY-MM-DD hh:mm') : null

    return {
      firstCheckIn: setTimeValue(defaultValues[0]?.check_in),
      firstCheckOut: setTimeValue(defaultValues[0]?.check_out),
      secondCheckIn: setTimeValue(defaultValues[1]?.check_in),
      secondCheckOut: setTimeValue(defaultValues[1]?.check_out)
    }
  }
  const [absence, setAbsence] = useState(
    defaultValues.find(v => v.absence)?.absence || null
  )
  const [checkInSelected, setCheckInSelected] = useState(false)
  const [checkOutSelected, setCheckOutSelected] = useState(false)
  const [showSecondCheckIn, setShowSecondCheckIn] = useState(
    secondCheckInExists()
  )
  const [timePickerValues, setTimePickerValues] = useState(
    createTimePickerValues()
  )
  const handleChange = options => {
    const { update = {}, callback = () => {}, secondCheckIn = false } = options
    updateAttendanceData({ update, record, columnIndex, secondCheckIn })
    callback()
  }

  useEffect(() => {
    if (defaultValues.length > 0) {
      setTimePickerValues(createTimePickerValues())
      setShowSecondCheckIn(secondCheckInExists())
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [defaultValues])

  const renderTimePicker = options => {
    return (
      <TimePicker
        className="w-20 h-8"
        style={{
          border: '1px solid #D9D9D9'
        }}
        value={options.value}
        use12Hours={true}
        format="h:mm a"
        disabled={options.disabled || false}
        onChange={options.onChange}
        suffixIcon={null}
      />
    )
  }

  return (
    <div className="flex flex-col m-">
      <div className="flex flex-row">
        <div className="mr-4">
          <p className="mb-1 font-semibold font-proxima-nova-alt">
            {t('checkIn').toUpperCase()}
          </p>
          {renderTimePicker({
            value: timePickerValues.firstCheckIn,
            disabled: absence,
            onChange: (dateObject, dateString) =>
              dateObject
                ? handleChange({
                    update: {
                      check_in:
                        (defaultValues[0]?.check_in?.slice(0, 11) || '') +
                        dateString
                    },
                    callback: () => {
                      setTimePickerValues(prevValues => ({
                        ...prevValues,
                        firstCheckIn: dateObject
                      }))
                      setCheckInSelected(true)
                    }
                  })
                : handleChange({
                    update: { check_in: '' },
                    callback: () => {
                      setTimePickerValues(prevValues => ({
                        ...prevValues,
                        firstCheckIn: null
                      }))
                      setCheckInSelected(false)
                    }
                  })
          })}
        </div>
        <div className="mr-4">
          <p className="mb-1 font-semibold font-proxima-nova-alt">
            {t('checkOut').toUpperCase()}
          </p>
          {renderTimePicker({
            value: timePickerValues.firstCheckOut,
            disabled: absence,
            onChange: (dateObject, dateString) =>
              dateObject
                ? handleChange({
                    update: {
                      check_out:
                        ((
                          defaultValues[0]?.check_out ||
                          defaultValues[0]?.check_in
                        )?.slice(0, 11) || '') + dateString
                    },
                    callback: () => {
                      setTimePickerValues(prevValues => ({
                        ...prevValues,
                        firstCheckOut: dateObject
                      }))
                      setCheckOutSelected(true)
                    }
                  })
                : handleChange({
                    update: { check_out: '' },
                    callback: () => {
                      setTimePickerValues(prevValues => ({
                        ...prevValues,
                        firstCheckOut: null
                      }))
                      setCheckOutSelected(false)
                    }
                  })
          })}
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
                  : handleChange({
                      update: { absence: null },
                      callback: setAbsence(null)
                    })
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
                    ? handleChange({
                        update: { absence: 'covid-related' },
                        callback: () => {
                          setShowSecondCheckIn(false)
                          setAbsence('covid-related')
                        }
                      })
                    : handleChange({
                        update: { absence: null },
                        callback: setAbsence(null)
                      })
                }
              />
              <span className="ml-3">
                {t('absent') + ' - ' + t('covidRelated')}
              </span>
            </p>
          )}
        </div>
      </div>
      <div className="flex flex-row mt-4">
        {showSecondCheckIn ? (
          <div className="flex">
            <div className="mr-4">
              <p className="mb-1 font-semibold font-proxima-nova-alt">
                {t('checkIn').toUpperCase()}
              </p>
              {renderTimePicker({
                value: timePickerValues.secondCheckIn,
                onChange: (dateObject, dateString) =>
                  dateObject
                    ? handleChange({
                        update: {
                          check_in:
                            (defaultValues[1]?.check_in?.slice(0, 11) ||
                              defaultValues[0]?.check_in?.slice(0, 11) ||
                              '') + dateString
                        },
                        callback: () =>
                          setTimePickerValues(prevValues => ({
                            ...prevValues,
                            secondCheckIn: dateObject
                          })),
                        secondCheckIn: true
                      })
                    : handleChange({
                        update: { check_in: '' },
                        callback: () =>
                          setTimePickerValues(prevValues => ({
                            ...prevValues,
                            secondCheckIn: null
                          })),
                        secondCheckIn: true
                      })
              })}
            </div>
            <div className="mr-4">
              <p className="mb-1 font-semibold font-proxima-nova-alt">
                {t('checkOut').toUpperCase()}
              </p>
              {renderTimePicker({
                value: timePickerValues.secondCheckOut,
                onChange: (dateObject, dateString) =>
                  dateObject
                    ? handleChange({
                        update: {
                          check_out:
                            (defaultValues[1]?.check_out?.slice(0, 11) ||
                              defaultValues[0]?.check_out?.slice(0, 11) ||
                              '') + dateString
                        },
                        callback: () =>
                          setTimePickerValues(prevValues => ({
                            ...prevValues,
                            secondCheckOut: dateObject
                          })),
                        secondCheckIn: true
                      })
                    : handleChange({
                        update: { check_out: '' },
                        callback: () =>
                          setTimePickerValues(prevValues => ({
                            ...prevValues,
                            secondCheckOut: null
                          })),
                        secondCheckIn: true
                      })
              })}
            </div>
            <div className="flex items-center">
              <Button
                type="text"
                className="flex font-semibold font-proxima-nova -ml-4"
                onClick={() => {
                  handleChange({
                    update: {
                      absence: null,
                      check_in: null,
                      check_out: null
                    },
                    callback: () =>
                      setTimePickerValues(prevValues => ({
                        ...prevValues,
                        ...{
                          secondCheckIn: null,
                          secondCheckOut: null
                        }
                      })),
                    secondCheckIn: true
                  })
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
    </div>
  )
}

AttendanceDataCell.propTypes = {
  columnDate: PropTypes.string,
  columnIndex: PropTypes.number,
  defaultValues: PropTypes.arrayOf(object),
  record: PropTypes.object,
  updateAttendanceData: PropTypes.func
}
