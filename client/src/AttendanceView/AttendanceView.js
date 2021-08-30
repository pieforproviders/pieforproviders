/* eslint-disable no-debugger */
import React, { useEffect, useState } from 'react'
import { Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function AttendanceView() {
  const { t } = useTranslation()
  const { makeRequest } = useApiResponse()
  const [attendanceData, setAttendanceData] = useState([])
  // columns will be current dates
  const { token } = useSelector(state => ({ token: state.auth.token }))
  const [
    dateSelected
    // setDateSelected
  ] = useState(dayjs())

  // create seven columns for each day of the week
  const generateColumns = () => {
    const dateColumns = []

    for (let i = 0; i < 7; i++) {
      const columnDate = dateSelected.day(i)
      dateColumns.push({
        dataIndex: i,
        key: i,
        width: 150,
        // eslint-disable-next-line react/display-name
        title: () => {
          return (
            <div className="text-gray9 grid justify-items-center ">
              <div>{columnDate.format('ddd').toLocaleLowerCase()} </div>
              <div className="font-semibold">{columnDate.format('MMM DD')}</div>
            </div>
          )
        },
        render: (_, record) => {
          return record
        }
      })
    }
    // set week start date:
    // get current day, reset to sunday, if not already sunday
    console.log(dateSelected)
    debugger

    return [
      {
        dataIndex: 'name',
        key: 'name',
        width: 150,
        title: (
          <div className="text-gray9 font-semibold grid justify-items-center ">
            Name
          </div>
        )
      },
      ...dateColumns
    ]
  }
  const [
    columns
    // setColumns when a new date/week is selected
  ] = useState(generateColumns())

  useEffect(() => {
    const getResponse = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/attendances',
        headers: {
          Authorization: token
        },
        data: {}
      })

      if (response.ok) {
        const parsedResponse = await response.json()
        const day = dayjs()
        console.log(day)
        console.log(cases)
        debugger
        setAttendanceData(parsedResponse)
      }
    }

    getResponse()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])
  // eslint-disable-next-line react/react-in-jsx-scope
  console.log(attendanceData)
  return (
    <div>
      <p className="h1-large mb-4 flex justify-center">{t('attendance')}</p>
      <Table
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
