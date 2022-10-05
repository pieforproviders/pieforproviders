import React, { useEffect, useState, useRef } from 'react'
import { Alert, Button, DatePicker, Modal, Table } from 'antd'
import { useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { useDispatch, useSelector } from 'react-redux'
import ellipse from '_assets/ellipse.svg'
import { PaddedButton } from '_shared/PaddedButton'
import { useCaseAttendanceData } from '_shared/_hooks/useCaseAttendanceData'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useProgress } from '_shared/_hooks/useProgress'
import { setBusinesses } from '_reducers/businessesReducer'
import { setCaseData } from '_reducers/casesReducer'
import { setFilteredCases } from '_reducers/uiReducer'
import { setLoading } from '_reducers/uiReducer'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import removeEmptyStringValue from '../_utils/removeEmptyStringValue'
import AttendanceDataCell from '_shared/AttendanceDataCell'
import SiteFilterSelect from '_shared/SiteFilterSelect'
import '_assets/styles/alert-overrides.css'
import '_assets/styles/filter-select-overrides.css'
import '_assets/styles/attendance-table-overrides.css'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import dayjs from 'dayjs'
import { LoadingDisplay } from '_shared/LoadingDisplay'
import customParseFormat from 'dayjs/plugin/customParseFormat'

dayjs.extend(customParseFormat)

export function Attendance() {
  const { t, i18n } = useTranslation()
  const { parseResult } = useProgress()
  const { sendGAEvent } = useGoogleAnalytics()
  const history = useHistory()
  const dispatch = useDispatch()
  const { reduceTableData } = useCaseAttendanceData()
  const { makeRequest } = useApiResponse()
  const { businesses, cases, isLoading, token, filteredCases } = useSelector(
    state => ({
      businesses: state.businesses,
      cases: state.cases,
      isLoading: state.ui.isLoading,
      token: state.auth.token,
      filteredCases: state.ui.filteredCases
    })
  )
  const [tableData, setTableData] = useState(cases)
  const [isSuccessModalVisible, setSuccessModalVisible] = useState(false)
  const [errors, setErrors] = useState(true)
  const reduceAttendanceData = data =>
    /* 
    accumulate an array of arrays of objects where the top-level key is the child id
    and each array item is an object with keys for absenceType and attendances (itself an array)
    */
    data.reduce((acc, cv) => {
      return {
        ...acc,
        ...{
          [cv.id]: [...Array(7).keys()].map(() => {
            return { absenceType: null, attendances: [{}, {}] }
          })
        }
      }
    }, {})
  const [attendanceData, setAttendanceData] = useState(
    reduceAttendanceData(cases)
  )
  const [columnDates, setColumnDates] = useState(
    [...Array(7).keys()].map(() => '')
  )
  const latestAttendanceData = useRef(attendanceData)
  const latestColumnDates = useRef(columnDates)
  const latestError = useRef(errors)

  const columnErrorIsPresent = columnIndex => {
    return (
      !!Object.values(latestAttendanceData.current).find(row => {
        return (
          row[columnIndex].attendances.some(
            attendance => Object.keys(attendance).length > 0
          ) || row[columnIndex].absenceType
        )
      }) && latestColumnDates.current[columnIndex] === ''
    )
  }

  const updateAttendanceData = ({
    update,
    record,
    columnIndex,
    secondCheckIn
  }) => {
    const newDayData = latestAttendanceData.current[record?.id].map(
      (day, index) => {
        const attendanceIndex = secondCheckIn ? 1 : 0
        // this logic adds and removes fields as needed depending on whether checkin/out or an absence is selected

        // if the index of this day on the case record's array of days
        // matches the index of the column in the table where the update is coming from, transform it
        let updatedAttendanceValue
        if (index === columnIndex) {
          // if there are no updates in the update object OR
          // the existing data includes absence AND the update includes check-in or check_out OR
          // the update includes absence AND the existing data includes check_in or check_out
          const attendanceUpdates = Object.keys(update)
            .filter(key => !key.includes('absenceType'))
            .reduce((obj, key) => {
              return Object.assign(obj, {
                [key]: update[key]
              })
            }, {})
          if (
            Object.keys(update).length === 0 ||
            (day.absenceType &&
              (Object.keys(update).includes('check_in') ||
                Object.keys(update).includes('check_out'))) ||
            (update.absenceType &&
              (Object.keys(day.attendances[attendanceIndex]).includes(
                'check_in'
              ) ||
                Object.keys(day.attendances[attendanceIndex]).includes(
                  'check_out'
                )))
          ) {
            // remove the empty string value from update and return it wholesale
            updatedAttendanceValue = removeEmptyStringValue(attendanceUpdates)
          } else {
            // otherwise, remove the empty string value from a spread of the existing data and the new data
            updatedAttendanceValue = removeEmptyStringValue({
              ...day.attendances[attendanceIndex],
              ...attendanceUpdates
            })
          }
        } else {
          // otherwise return the day as normal to the map
          updatedAttendanceValue = day.attendances[attendanceIndex]
        }

        return {
          absenceType:
            index === columnIndex
              ? update.absenceType || day.absenceType
              : day.absenceType,
          attendances: day.attendances.map((v, i) =>
            attendanceIndex === i ? updatedAttendanceValue : v
          )
        }
      }
    )

    const updatedReference = {
      ...latestAttendanceData.current,
      [record.id]: newDayData
    }
    latestAttendanceData.current = updatedReference

    const errorIsPresent = columnErrorIsPresent(columnIndex)

    if (errorIsPresent !== latestError.current) {
      latestError.current = errorIsPresent
      setErrors(errorIsPresent)
      setColumns(generateColumns())
    }
    setAttendanceData(prevData => {
      return { ...prevData, [record.id]: newDayData }
    })
  }

  const handleDateChange = (index, dateString) => {
    const updatedDates = latestColumnDates.current.map((value, i) =>
      index === i ? dateString : value
    )
    latestColumnDates.current = updatedDates
    const errorIsPresent = columnErrorIsPresent(index)

    if (errorIsPresent !== latestError.current) {
      latestError.current = errorIsPresent
      setErrors(errorIsPresent)
    }
    setColumns(generateColumns(updatedDates))
    setColumnDates(updatedDates)
  }

  const generateColumns = (updatedDates = null) => {
    let cols = []
    for (let i = 0; i < 7; i++) {
      cols.push({
        dataIndex: 'date' + i,
        key: 'date' + i,
        width: 398,
        // eslint-disable-next-line react/display-name
        title: () => {
          return (
            <div className="flex items-center">
              <DatePicker
                disabledDate={c => c && c.valueOf() > Date.now()}
                onChange={(_, ds) => handleDateChange(i, ds)}
                bordered={false}
                placeholder={t('selectDate')}
                style={{ width: '8rem ', color: '#004A6E' }}
              />
              {columnErrorIsPresent(i) ? (
                <div className="font-semibold text-red1">{t('dateError')}</div>
              ) : null}
            </div>
          )
        },
        // eslint-disable-next-line react/display-name
        render: (text, record, index) => {
          return (
            <AttendanceDataCell
              record={record}
              columnIndex={i}
              columnDate={updatedDates === null ? '' : updatedDates[i]}
              updateAttendanceData={updateAttendanceData}
            />
          )
        }
      })
    }

    return [
      {
        title: (
          <div className="font-semibold text-gray9">{t('childNameCap')}</div>
        ),
        dataIndex: 'name',
        width: 250,
        key: 'name',
        // eslint-disable-next-line react/display-name
        render: (_, record) => {
          const firstName = record.childFirstName || record.child.childFirstName
          const lastName = record.childLastName || record.child.childLastName
          return (
            <div>
              <p className="mb-1 text-lg">{`${firstName} ${lastName}`}</p>
              <p className="flex flex-wrap mt-0.5">
                {record.business || record.child.business}{' '}
                <img className="mx-1" alt="ellipse" src={ellipse} />{' '}
                {record.cNumber || record.child.cNumber}
              </p>
            </div>
          )
        }
      },
      ...cols
    ]
  }

  const [columns, setColumns] = useState(generateColumns())

  i18n.on('languageChanged', () => setColumns(generateColumns()))

  const handleSave = async () => {
    let responses = []
    // TODO Refactor: find a more compact way to do this between Attendance
    // and AttendanceView to remove duplicate code and comparison logic
    const formatAttendanceData = ({ check_in, check_out, date }) => {
      const checkIn = check_in ? dayjs(`${date} ${check_in}`) : null
      const checkOut = check_out ? dayjs(`${date} ${check_out}`) : null
      return {
        check_in: checkIn ? checkIn.format() : null,
        check_out: checkOut
          ? checkIn.isAfter(checkOut)
            ? checkOut.add(1, 'day').format()
            : checkOut.format()
          : null
      }
    }

    const absenceRequests = Object.entries(attendanceData).flatMap(record => {
      return record[1]
        .filter(day => day.absenceType)
        .flatMap((day, index) => {
          return {
            service_day: {
              child_id: record[0],
              date: dayjs(columnDates[index]),
              absence_type: day.absenceType
            }
          }
        })
    })

    const attendanceBatch = Object.entries(attendanceData).flatMap(record => {
      // record[1] = mapped record value = all the service days for a child
      return record[1]
        .map((serviceDay, index) => {
          // tack on the date of the record before filtering
          if (
            serviceDay.attendances.some(
              attendance => Object.keys(attendance).length > 0
            )
          ) {
            serviceDay.attendances.map(attendance => {
              if (Object.keys(attendance).length > 0) {
                attendance.date = latestColumnDates.current[index]
              }
              return attendance
            })
          }
          return serviceDay
        })
        .filter(
          // filter out days that are not absences and are not attendances
          day =>
            !day.absenceType &&
            day.attendances.filter(
              attendance => Object.keys(attendance).length > 0
            ).length > 0
        )
        .flatMap(day => {
          return (
            day.attendances
              // filter out attendances with no check-in or check-out
              .filter(attendance => Object.keys(attendance).length > 0)
              .flatMap(attendance => {
                const formattedDates = formatAttendanceData(attendance)
                return {
                  check_in: formattedDates.check_in,
                  check_out: formattedDates.check_out,
                  child_id: record[0] // record[0] = mapped record key = child_id
                }
              })
          )
        })
    })

    if (attendanceBatch.length > 0) {
      const response = await makeRequest({
        type: 'post',
        url: '/api/v1/attendance_batches',
        headers: {
          Authorization: token
        },
        data: {
          attendance_batch: attendanceBatch
        }
      })
      responses.push(response)
    }

    if (absenceRequests.length > 0) {
      absenceRequests.forEach(async request => {
        const response = await makeRequest({
          type: 'post',
          url: '/api/v1/service_days',
          headers: {
            Authorization: token
          },
          data: request
        })
        responses.push(response)
      })
    }

    const responsesOk = responses.every(r => r.ok)

    if (!responsesOk) {
      // TODO: handle bad request
      console.log('error sending attendance data to API')
    } else {
      setSuccessModalVisible(true)
      // implemented per: https://help.hotjar.com/hc/en-us/articles/4405109971095-Events-API-Reference
      window.hj =
        window.hj ||
        function () {
          // eslint-disable-next-line no-undef
          ;(hj.q = hj.q || []).push(arguments)
        }
      window.hj('event', 'save_attendance')
      sendGAEvent('save_attendance', {
        number: `${attendanceBatch.length}`,
        page_title: 'edit_attendance'
      })
    }
  }

  const getCaseData = async (businessIds = []) => {
    dispatch(setLoading(true))

    const url =
      businessIds.length > 0
        ? `/api/v1/children?business=${businessIds.join(',')}`
        : '/api/v1/children'
    const request = {
      type: 'get',
      url: url,
      headers: { Authorization: token }
    }
    const response = await makeRequest(request)

    if (response.ok) {
      const parsedResponse = await parseResult(response)
      const caseData = reduceTableData(parsedResponse)
      const reducedAttendanceData = reduceAttendanceData(caseData)

      if (businesses.length === 0) {
        const businessData = parsedResponse.reduce((priorValue, newValue) => {
          return !priorValue.some(item => item.id === newValue.business.id)
            ? [...priorValue, newValue.business]
            : priorValue
        }, [])
        dispatch(setBusinesses(businessData))
      }
      dispatch(setFilteredCases(businessIds))
      dispatch(setCaseData(caseData))
      latestAttendanceData.current = reducedAttendanceData
      setAttendanceData(reducedAttendanceData)
      setTableData(caseData)
    }
    dispatch(setLoading(false))
  }

  useEffect(() => {
    getCaseData(filteredCases)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div>
      <p className="flex justify-center mb-4 h1-large">
        {t('enterAttendance')}
      </p>
      <Alert
        className="attendance-alert"
        message={
          <div className="text-gray1">
            <div>
              <span className="font-bold">{t('important')}</span>
              {t('attendanceWarning') + ' ' + t('attendanceQuestions') + ' '}
              <a
                className="underline"
                href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}
              >
                {PIE_FOR_PROVIDERS_EMAIL + '.'}
              </a>
            </div>
            <div>
              <span className="font-bold">{t('pleaseNote')}</span>
              {' ' + t('pleaseNoteMsg')}
            </div>
          </div>
        }
        type="error"
        closable
      />
      <div className="relative pt-5">
        <SiteFilterSelect
          businesses={businesses}
          onChange={value => {
            getCaseData(value)
          }}
        />
      </div>
      <Table
        dataSource={tableData.filter(c => c.active)}
        columns={columns}
        bordered={true}
        pagination={false}
        sticky
        scroll={{ x: 1500 }}
        className="my-5 attendance-table"
        loading={{
          delay: 1000,
          spinning: isLoading,
          indicator: <LoadingDisplay />
        }}
      />
      <div className="flex justify-center">
        <PaddedButton
          classes="mt-3 w-40 bg-primaryBlue"
          text={t('save')}
          onClick={handleSave}
          disabled={latestError.current}
        />
      </div>
      <Modal
        title={<div className="eyebrow-large text-gray9">{t('success')}</div>}
        visible={isSuccessModalVisible}
        onCancel={() => {
          setSuccessModalVisible(false)
          history.push('/dashboard')
        }}
        footer={[
          <Button
            type="primary"
            className="bg-primaryBlue"
            key="ok"
            onClick={() => {
              setSuccessModalVisible(false)
              history.push('/dashboard')
            }}
          >
            {t('gotToDashboard')}
          </Button>
        ]}
      >
        <p>{t('successText')}</p>
      </Modal>
    </div>
  )
}
