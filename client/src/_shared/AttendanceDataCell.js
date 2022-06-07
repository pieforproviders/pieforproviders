import React, { useEffect, useState } from 'react'
import PropTypes from 'prop-types'
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
  defaultValues = { absenceType: null, attendances: [] },
  updateAttendanceData = () => {},
  reset = null
}) {
  useEffect(() => {
    setCheckInSelected(false)
    setCheckOutSelected(false)
  }, [record])

  const { t } = useTranslation()
  const secondCheckInExists = () =>
    Object.keys(defaultValues.attendances[1] || {}).length > 0

  const createTimePickerValues = () => {
    const setTimeValue = value =>
      value ? dayjs(value, 'YYYY-MM-DD hh:mm') : null
    return {
      firstCheckIn: absence
        ? null
        : setTimeValue(defaultValues.attendances[0]?.check_in),
      firstCheckOut: absence
        ? null
        : setTimeValue(defaultValues.attendances[0]?.check_out),
      secondCheckIn: absence
        ? null
        : setTimeValue(defaultValues.attendances[1]?.check_in),
      secondCheckOut: absence
        ? null
        : setTimeValue(defaultValues.attendances[1]?.check_out)
    }
  }
  const [absence, setAbsence] = useState(defaultValues.absenceType || null)
  const [checkInSelected, setCheckInSelected] = useState(false)
  const [checkOutSelected, setCheckOutSelected] = useState(false)
  const [showSecondCheckIn, setShowSecondCheckIn] = useState(
    secondCheckInExists() && !absence
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
    if (defaultValues.attendances.length > 0) {
      setTimePickerValues(createTimePickerValues())
      setShowSecondCheckIn(secondCheckInExists() && !absence)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [absence])

  useEffect(() => {
    if (defaultValues.attendances.length > 0) {
      setTimePickerValues(createTimePickerValues())
      setShowSecondCheckIn(secondCheckInExists() && !absence)
      setAbsence(defaultValues.absenceType || null)
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
                        (defaultValues.attendances[0]?.check_in?.slice(0, 11) ||
                          '') + dateString
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
                          defaultValues.attendances[0]?.check_out ||
                          defaultValues.attendances[0]?.check_in
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
                /* disable this box if the absence is already marked as covid-related, or if check-in/out is selected */
                absence === 'covid-related' ||
                checkInSelected ||
                checkOutSelected
              }
              onChange={e => {
                e.target.checked
                  ? handleChange({
                      update: { absenceType: 'absence' },
                      callback: () => {
                        setShowSecondCheckIn(false)
                        setAbsence('absence')
                      }
                    })
                  : handleChange({
                      update: { absenceType: null },
                      callback: () => {
                        setAbsence(null)
                      }
                    })
              }}
            />
            <span className="ml-3">{t('absent')}</span>
          </p>
          {
            /* show COVID checkbox before 2021-07-31 */
            columnDate && new Date(columnDate) <= new Date('2021-07-31') && (
              <p className="mt-2">
                <Checkbox
                  className="absence"
                  checked={absence === 'covid-related'}
                  disabled={
                    /* disable this box if the absence is already marked as a regular absence, or if check-in/out is selected */
                    absence === 'absence' || checkInSelected || checkOutSelected
                  }
                  onChange={e =>
                    e.target.checked
                      ? handleChange({
                          update: { absenceType: 'covid-related' },
                          callback: () => {
                            setShowSecondCheckIn(false)
                            setAbsence('covid-related')
                          }
                        })
                      : handleChange({
                          update: { absenceType: null },
                          callback: setAbsence(null)
                        })
                  }
                />
                <span className="ml-3">
                  {t('absent') + ' - ' + t('covidRelated')}
                </span>
              </p>
            )
          }
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
                            (defaultValues.attendances[1]?.check_in?.slice(
                              0,
                              11
                            ) ||
                              defaultValues.attendances[0]?.check_in?.slice(
                                0,
                                11
                              ) ||
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
                            (defaultValues.attendances[1]?.check_out?.slice(
                              0,
                              11
                            ) ||
                              defaultValues.attendances[0]?.check_out?.slice(
                                0,
                                11
                              ) ||
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
                className="flex -ml-4 font-semibold font-proxima-nova"
                onClick={() => {
                  handleChange({
                    update: {
                      absenceType: null,
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
                <p className="ml-1 text-red1">{t('removeCheckInTime')}</p>
              </Button>
            </div>
          </div>
        ) : (
          <div className="mt-4">
            <Button
              disabled={absence}
              type="text"
              className="flex -ml-4 font-semibold font-proxima-nova"
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
  defaultValues: PropTypes.object,
  record: PropTypes.object,
  updateAttendanceData: PropTypes.func,
  reset: PropTypes.bool
}
