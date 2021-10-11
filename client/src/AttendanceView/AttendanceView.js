import React, { useEffect, useState } from 'react'
import { Button, Grid, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import smallPie from '../_assets/smallPie.png'
import { WeekPicker } from './WeekPicker'

const { useBreakpoint } = Grid

export function AttendanceView() {
  const { i18n, t } = useTranslation()
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
              {/* TODO ADD MONTH translation logic */}
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

  const handleDateChange = newDate => setDateSelected(newDate)

  useEffect(() => {
    const getResponse = async () => {
      const response = await makeRequest({
        type: 'get',
        url:
          '/api/v1/attendances?filter_date=' +
          dateSelected.format('YYYY-MM-DD'),
        headers: {
          Authorization: token
        },
        data: {}
      })

      if (response.ok) {
        const parsedResponse = await response.json()
        const reducedAttendanceData = parsedResponse.reduce(
          (accumulator, currentValue) => {
            // eslint-disable-next-line no-constant-condition
            if (
              accumulator.some(e => e.child === currentValue.child.full_name)
            ) {
              return accumulator.map(child => {
                if (child.child === currentValue.child.full_name) {
                  return {
                    child: child.child,
                    attendances: [...child.attendances, currentValue]
                  }
                } else {
                  return child
                }
              })
            } else {
              return [
                ...accumulator,
                // eslint-disable-next-line prettier/prettier
                { child: currentValue.child.full_name, attendances: [currentValue] }
              ]
            }
          },
          []
        )

        setAttendanceData(reducedAttendanceData)
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
              onClick={() => history.push('/attendance/edit')}
              data-cy="inputAttendance"
            >
              {t('inputAttendance')}
            </Button>
          </div>
          <p>
            <WeekPicker
              dateSelected={dateSelected}
              handleDateChange={handleDateChange}
            />
          </p>
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
