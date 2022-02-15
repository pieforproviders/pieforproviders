import React, { useEffect, useRef, useState } from 'react'
import { Button, Grid, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import smallPie from '../_assets/smallPie.png'
import editIcon from '../_assets/editIcon.svg'
import { WeekPicker } from './WeekPicker'
import { EditAttendanceModal } from './EditAttendanceModal'

const { useBreakpoint } = Grid

export function AttendanceView() {
  const { i18n, t } = useTranslation()
  const { sendGAEvent } = useGoogleAnalytics()
  const screens = useBreakpoint()
  const history = useHistory()
  const { makeRequest } = useApiResponse()
  const [attendanceData, setAttendanceData] = useState([])
  // columns will be current dates
  const { token } = useSelector(state => ({ token: state.auth.token }))
  const [dateSelected, setDateSelected] = useState(dayjs())
  const [editAttendanceModalData, setEditAttendanceModalData] = useState(null)
  const [updatedAttendanceData, setUpdatedAttendanceData] = useState([{}, {}])
  const [modalButtonDisabled, setModalButtonDisabled] = useState(false)
  const latestAttendanceData = useRef(updatedAttendanceData)
  const titleData = useRef({ childName: null, columnDate: null })

  const updateAttendanceData = data => {
    const index = data.secondCheckIn ? 1 : 0
    const updatedData = latestAttendanceData.current.map((value, i) => {
      if (index === i) {
        const updatedValueKeys = Object.keys(data.update)
        const currentValueKeys = Object.keys(value)
        const updatedValue =
          updatedValueKeys.length === 0 ||
          (currentValueKeys.includes('absence') &&
            (updatedValueKeys.includes('check_in') ||
              updatedValueKeys.includes('check_out'))) ||
          (updatedValueKeys.includes('absence') &&
            (currentValueKeys.includes('check_in') ||
              currentValueKeys.includes('check_out')))
            ? data.update
            : { ...value, ...data.update }
        const mergedValue =
          Object.keys(value).length === 0
            ? {
                child_id: data.record?.serviceDays[0]?.child_id || '',
                ...updatedValue
              }
            : {
                ...value,
                ...updatedValue
              }

        // disabled saving on modal if only checkout time exists
        if (index === 0) {
          setModalButtonDisabled(
            !(mergedValue.check_in || mergedValue.absence) &&
              mergedValue.check_out
          )
        }
        return mergedValue
      }

      return value
    })

    latestAttendanceData.current = updatedData
    setUpdatedAttendanceData(updatedData)
  }

  // create seven columns for each day of the week
  const generateColumns = () => {
    const dateColumns = []

    for (let i = 0; i < 7; i++) {
      const columnDate = dateSelected.day(i)
      dateColumns.push({
        dataIndex: i,
        key: i,
        width: 275,
        // eslint-disable-next-line react/display-name
        title: () => {
          const monthDate = columnDate.format('MMM DD')
          return (
            <div className="grid text-gray9 justify-items-center ">
              <div>{t(`${columnDate.format('ddd').toLocaleLowerCase()}`)} </div>
              <div className="font-semibold">{`${t(
                monthDate.slice(0, 3).toLowerCase()
              )} ${monthDate.slice(4, 6)}`}</div>
            </div>
          )
        },
        // eslint-disable-next-line react/display-name
        render: (_, record) => {
          const matchingServiceDay = record.serviceDays.find(serviceDay => {
            return new RegExp(columnDate.format('YYYY-MM-DD')).test(
              serviceDay.date
            )
          })
          const hideEditButton =
            matchingServiceDay?.attendances.some(
              attendance => attendance.wonderschool_id
            ) || false

          const handleEditAttendance = () => {
            const currentAttendances =
              record.serviceDays.find(
                day => day.date.slice(0, 10) === columnDate.format('YYYY-MM-DD')
              ).attendances || []
            const attendances =
              currentAttendances.length === 1
                ? [...currentAttendances, {}]
                : currentAttendances

            setEditAttendanceModalData({
              record,
              columnDate: columnDate.format('YYYY-MM-DD'),
              defaultValues: attendances,
              updateAttendanceData
            })

            titleData.current = {
              childName: record.child,
              columnDate
            }
            latestAttendanceData.current = attendances
            setUpdatedAttendanceData(attendances)
          }

          if (matchingServiceDay !== undefined) {
            if (matchingServiceDay.tags.includes('absence')) {
              return (
                <div>
                  {hideEditButton ? null : (
                    <button
                      className="float-right"
                      onClick={handleEditAttendance}
                    >
                      <img alt="editButton" src={editIcon} />
                    </button>
                  )}
                  <div className="flex justify-center">
                    <div
                      className="box-border p-1 bg-orange2 text-orange3"
                      data-cy="absent"
                    >
                      {t('absent').toLowerCase()}
                    </div>
                  </div>
                </div>
              )
            }
            const checkInCheckOutTime = matchingServiceDay.attendances
              .map(attendance => {
                const check_in = dayjs(
                  attendance.check_in,
                  'YYYY-MM-DD hh:mm'
                ).format('h:mm a')
                const check_out = attendance.check_out
                  ? dayjs(attendance.check_out, 'YYYY-MM-DD hh:mm').format(
                      'h:mm a'
                    )
                  : 'no check out time'
                return `${check_in} - ${check_out}`
              })
              .join(', ')
            const hour = Math.floor(
              Number(matchingServiceDay.total_time_in_care) / 3600
            )
            const minute = Math.floor(
              Number(matchingServiceDay.total_time_in_care % 3600) / 60
            )
            const totalTimeInCare = hour + ' hrs ' + minute + ' mins'

            return (
              <div className="text-center body-2">
                {hideEditButton ? null : (
                  <button
                    className="float-right"
                    onClick={handleEditAttendance}
                  >
                    <img alt="edit" src={editIcon} />
                  </button>
                )}
                <div className="mb-2 text-gray8 font-semiBold">
                  {totalTimeInCare}
                </div>
                <div className="text-xs text-darkGray">
                  {checkInCheckOutTime}
                </div>
                <div className="flex justify-center">
                  {(matchingServiceDay.tags || []).map((tag, i) => (
                    <div
                      key={i}
                      className={`bg-green2 text-green1 box-border p-1 mt-1 ${
                        i > 0 ? 'ml-1' : null
                      }`}
                    >
                      {t(`${tag.toLowerCase()}`)}
                    </div>
                  ))}
                </div>
              </div>
            )
          }
          return (
            <div className="flex justify-center">
              <div className="box-border p-1 bg-mediumGray" data-cy="noInfo">
                {t('noInfo')}
              </div>
            </div>
          )
        }
      })
    }

    return [
      {
        dataIndex: 'name',
        key: 'name',
        width: 150,
        title: (
          <div className="grid font-semibold text-gray9 justify-items-center ">
            {t('name')}
          </div>
        ),
        // eslint-disable-next-line react/display-name
        render: (_, record) => (
          <div className="eyebrow-large text-gray1">{record.child}</div>
        )
      },
      ...dateColumns
    ]
  }
  const [columns, setColumns] = useState(generateColumns())
  i18n.on('languageChanged', () => setColumns(generateColumns()))

  const handleDateChange = newDate => {
    // send google analytics event data about changing the current week selected
    sendGAEvent('dates_filtered', {
      date_selected: `${newDate.weekday(0).format('MMM D')} -
      ${newDate.weekday(6).format('MMM D, YYYY')}`,
      page_title: 'attendance'
    })

    setDateSelected(newDate)
  }

  const getServiceDays = async () => {
    const response = await makeRequest({
      type: 'get',
      url:
        '/api/v1/service_days?filter_date=' + dateSelected.format('YYYY-MM-DD'),
      headers: {
        Authorization: token
      },
      data: {}
    })

    if (response.ok) {
      const parsedResponse = await response.json()
      const addServiceDay = (previousValue, currentValue) => {
        const childName = currentValue.attendances[0].child.full_name
        const index = previousValue.findIndex(item => item.child === childName)
        index >= 0
          ? previousValue[index].serviceDays.push(currentValue)
          : previousValue.push({
              child: childName,
              serviceDays: [currentValue]
            })
        return previousValue
      }

      const reducedData = parsedResponse.reduce(addServiceDay, [])

      setAttendanceData(reducedData)
      setColumns(generateColumns())
    }
  }

  const handleModalClose = async () => {
    let responses = []

    updatedAttendanceData.forEach(async attendance => {
      // if it's an old attendance we call the attendances PUT endpoint,
      // if the user creates a new, second attendance for that day we need to call the attendance_batches endpoint
      // if the attendance values needed are all null the attendance needs to be deleted
      if (
        !attendance.absence &&
        !attendance.check_in &&
        !attendance.check_out &&
        attendance.id
      ) {
        const response = await makeRequest({
          type: 'del',
          url: '/api/v1/attendances/' + attendance.id,
          headers: {
            Authorization: token
          }
        })
        responses.push(response)
      } else if (Object.keys(attendance).includes('child_id')) {
        const response = await makeRequest({
          type: 'post',
          url: '/api/v1/attendance_batches',
          headers: {
            Authorization: token
          },
          data: {
            attendance_batch: [attendance]
          }
        })
        responses.push(response)
      } else if (Object.keys(attendance).length > 0) {
        // if new checkout add column date
        // if deleting checkout send null
        const formatDate = dateValue =>
          dateValue === ''
            ? null
            : dateValue?.slice(0, 10) !== editAttendanceModalData.columnDate
            ? `${editAttendanceModalData.columnDate} ${dateValue}`
            : dateValue

        const response = await makeRequest({
          type: 'put',
          url: '/api/v1/attendances/' + attendance.id,
          headers: {
            Authorization: token
          },
          data: {
            attendance: {
              check_in: formatDate(attendance.check_in),
              check_out: formatDate(attendance.check_out),
              absence: attendance.absence
            }
          }
        })
        responses.push(response)
      }
    })

    const responsesOk = responses.every(r => r.ok)

    if (!responsesOk) {
      console.log('error sending attendance data to API')
    }

    titleData.current = {
      childName: null,
      columnDate: null
    }
    latestAttendanceData.current = [{}, {}]
    setEditAttendanceModalData(null)
    setUpdatedAttendanceData([{}, {}])
  }

  useEffect(() => {
    getServiceDays()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dateSelected])

  return (
    <div>
      {screens.sm ? (
        <div>
          <div className="flex justify-center mb-4 h1-large">
            <div>
              <div>{t('attendance')}</div>
            </div>
            <Button
              type="primary"
              className="absolute"
              style={{ right: '3rem' }}
              onClick={() => {
                sendGAEvent('attendance_input_clicked', {
                  page_title: 'attendance'
                })
                history.push('/attendance/edit')
              }}
              data-cy="inputAttendance"
            >
              {t('inputAttendance')}
            </Button>
          </div>
          <div>
            <WeekPicker
              hasNext={dateSelected.day(6) < dayjs().day(0)}
              dateSelected={dateSelected}
              handleDateChange={handleDateChange}
            />
          </div>
          <Table
            dataSource={[...attendanceData]}
            columns={columns}
            bordered={true}
            pagination={false}
            sticky
            scroll={{ x: 1500 }}
            className="my-5"
          />
        </div>
      ) : (
        <div className="flex flex-col">
          <div className="mb-8 font-semibold text-center h3-large">
            {t('screenSize')}
          </div>
          <img src={smallPie} alt={'a small lemon pie'} />
          <div className="mt-8 text-center text-black body-1">
            {t('incompatibleMsg')}
          </div>
        </div>
      )}
      <EditAttendanceModal
        editAttendanceModalData={editAttendanceModalData}
        handleModalClose={async () => {
          await handleModalClose()
          getServiceDays()
        }}
        modalButtonDisabled={modalButtonDisabled}
        setEditAttendanceModalData={setEditAttendanceModalData}
        setUpdatedAttendanceData={setUpdatedAttendanceData}
        titleData={titleData.current}
      />
    </div>
  )
}
