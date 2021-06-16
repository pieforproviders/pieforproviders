/* eslint-disable no-debugger */
import React, { useState } from 'react'
import { Alert, DatePicker, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import merge from 'deepmerge'
import ellipse from '_assets/ellipse.svg'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import AttendanceDataCell from './AttendanceDataCell'
import '_assets/styles/alert-overrides.css'

// TODO: figure out logic for adding columns
// figure out logic for updating dates data
//  figure out logic for
export function Attendance() {
  const { t } = useTranslation()
  const cases = useSelector(state => state.cases)
  const [attendanceData, setAttendanceData] = useState(() =>
    cases.reduce((acc, cv) => {
      return {
        ...acc,
        ...{
          [cv.id]: [...Array(7).keys()].map(() => ({}))
        }
      }
    }, {})
  )

  const [columns] = useState(() => {
    let cols = []
    for (let i = 0; i < 7; i++) {
      cols.push({
        dataIndex: 'date' + i,
        key: 'date' + i,
        width: 398,
        // eslint-disable-next-line react/display-name
        title: () => <DatePicker bordered={false} />,
        // eslint-disable-next-line react/display-name
        render: (_, record, i) => {
          const boop = merge({}, { hi: 'hi' })
          console.log(boop)
          debugger
          return (
            <AttendanceDataCell
              updateAttendanceData={updates => {
                console.log(attendanceData)
                console.log(updates)
                console.log(record)
                console.log(i)
                debugger
                setAttendanceData(attendanceData)
              }}
            />
          )
        }
      })
    }

    return [
      {
        title: 'Child Name',
        dataIndex: 'name',
        width: 200,
        key: 'name',
        // eslint-disable-next-line react/display-name
        render: (_, record) => {
          return (
            <div>
              <p className="text-lg mb-1">{record.childName}</p>
              <p className="flex flex-wrap mt-0.5">
                {record.business}{' '}
                <img className="mx-1" alt="ellipse" src={ellipse} />{' '}
                {record.cNumber}
              </p>
            </div>
          )
        }
      },
      ...cols
    ]
  })

  return (
    <div>
      <p className="h1-large mb-4 flex justify-center">
        {t('enterAttendance')}
      </p>
      <p>
        <Alert
          className="attendance-alert"
          message={
            <div className="text-gray1">
              <span className="font-bold">{t('important')}</span>
              {t('attendanceWarning') + ' ' + t('attendanceQuestions') + ' '}
              <a
                className="underline"
                href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}
              >
                {PIE_FOR_PROVIDERS_EMAIL}
              </a>
            </div>
          }
          type="error"
          closable
        />
        <Table
          dataSource={cases}
          columns={columns}
          bordered={true}
          // size={'medium'}
          pagination={false}
          sticky
          scroll={{ x: 1500 }}
          className="my-5"
        ></Table>
      </p>
    </div>
  )
}
