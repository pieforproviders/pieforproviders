import React, { useEffect, useState } from 'react'
import { Button, Grid, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import smallPie from '../_assets/smallPie.png'
import { WeekPicker } from './WeekPicker'

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
            <div className="text-gray9 grid justify-items-center ">
              <div>{t(`${columnDate.format('ddd').toLocaleLowerCase()}`)} </div>
              <div className="font-semibold">{`${t(
                monthDate.slice(0, 3).toLowerCase()
              )} ${monthDate.slice(4, 6)}`}</div>
            </div>
          )
        },
        // eslint-disable-next-line react/display-name
        render: (_, record) => {
          const matchingAttendances = record.attendances.filter(attendance => {
            return new RegExp(columnDate.format('YYYY-MM-DD')).test(
              attendance.check_in
            )
          })

          if (matchingAttendances.length > 0) {
            if (
              matchingAttendances.some(attendance =>
                attendance.tags.includes('absence')
              )
            ) {
              return (
                <div className="flex justify-center">
                  <div
                    className="bg-orange2 text-orange3 box-border p-1"
                    data-cy="absent"
                  >
                    {t('absent').toLowerCase()}
                  </div>
                </div>
              )
            }

            let totalCareTime = '',
              checkInCheckOutTime = ''
            matchingAttendances.forEach(attendance => {
              const checkIn = dayjs(attendance.check_in).format('h:mm a')
              const checkOut = attendance.check_out
                ? dayjs(attendance.check_out).format('h:mm a')
                : 'no check out time'
              checkInCheckOutTime =
                checkInCheckOutTime.length > 0
                  ? checkInCheckOutTime + ', ' + checkIn + ' - ' + checkOut
                  : checkIn + ' - ' + checkOut

              const hour = Math.floor(
                Number(attendance.total_time_in_care) / 3600
              )
              const minute = Math.floor(
                Number(attendance.total_time_in_care % 3600) / 60
              )
              totalCareTime =
                totalCareTime.length > 0
                  ? totalCareTime + ', ' + hour + ' hrs ' + minute + '  mins'
                  : hour + ' hrs ' + minute + '  mins'
            })
            return (
              <div className="body-2 text-center">
                <div className="text-gray8 font-semiBold mb-2">
                  {totalCareTime}
                </div>
                <div className="text-darkGray text-xs">
                  {checkInCheckOutTime}
                </div>
                <div className="flex justify-center">
                  {(matchingAttendances[0]?.tags || []).map((tag, i) => (
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
              <div className="bg-mediumGray box-border p-1" data-cy="noInfo">
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
          <div className="text-gray9 font-semibold grid justify-items-center ">
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

  useEffect(() => {
    const getResponse = async () => {
      const response = await makeRequest({
        type: 'get',
        url:
          '/api/v1/service_days?filter_date=' +
          dateSelected.format('YYYY-MM-DD'),
        headers: {
          Authorization: token
        },
        data: {}
      })

      if (response.ok) {
        const parsedResponse = await response.json()
        const reducedData = parsedResponse
          // creates attendance cell objects that work with ant table component
          .map(serviceDay => {
            return {
              child: serviceDay.attendances[0]?.child?.full_name || '',
              attendances: serviceDay.attendances.map(attendance => ({
                ...attendance,
                ...{ tags: serviceDay.tags }
              }))
            }
          })
          // merge attendances for each child
          .reduce((acc, cv) => {
            const child = acc.find(element => element.child === cv.child)
            if (child) {
              acc[acc.indexOf(child)][`attendances`] = acc[acc.indexOf(child)][
                `attendances`
              ].concat(cv.attendances)
              return acc
            } else {
              return [...acc, cv]
            }
          }, [])

        setAttendanceData(reducedData)
        setColumns(generateColumns())
      }
    }

    getResponse()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [dateSelected])

  return (
    <div>
      {screens.sm ? (
        <div>
          <div className="h1-large mb-4 flex justify-center">
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
            dataSource={attendanceData}
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
          <div className="h3-large text-center mb-8 font-semibold">
            {t('screenSize')}
          </div>
          <img src={smallPie} alt={'a small lemon pie'} />
          <div className="text-center body-1 text-black mt-8">
            {t('incompatibleMsg')}
          </div>
        </div>
      )}
    </div>
  )
}
