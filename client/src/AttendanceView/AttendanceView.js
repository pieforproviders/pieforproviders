import React, { useEffect, useState } from 'react'
import { Button, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { WeekPicker } from './WeekPicker'

export function AttendanceView() {
  const { t } = useTranslation()
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
          return (
            <div className="text-gray9 grid justify-items-center ">
              <div>{columnDate.format('ddd').toLocaleLowerCase()} </div>
              <div className="font-semibold">{columnDate.format('MMM DD')}</div>
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
              const checkIn = dayjs(attendance.check_in)
              const checkOut = dayjs(attendance.check_out)
              checkInCheckOutTime =
                checkInCheckOutTime.length > 0
                  ? checkInCheckOutTime +
                    ', ' +
                    checkIn.format('h:mm a') +
                    ' - ' +
                    checkOut.format('h:mm a')
                  : checkIn.format('h:mm a') + ' - ' + checkOut.format('h:mm a')

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
                <div className="text-darkGray">{checkInCheckOutTime}</div>
              </div>
            )
          }
          return (
            <div className="flex justify-center">
              <div className="bg-mediumGray box-border p-1">no info</div>
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
            Name
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
      <div className="h1-large mb-4 flex justify-center">
        <div>
          <div>{t('attendance')}</div>
        </div>
        <Button className="ml-auto">Input Attendance</Button>
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
  )
}
