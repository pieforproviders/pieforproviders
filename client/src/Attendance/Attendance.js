import React, { useEffect, useState, useRef } from 'react'
import { Alert, Button, DatePicker, Modal, Table } from 'antd'
import { useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { useDispatch, useSelector } from 'react-redux'
import ellipse from '_assets/ellipse.svg'
import { PaddedButton } from '_shared/PaddedButton'
import { useCaseData } from '_shared/_hooks/useCaseData'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { setCaseData } from '_reducers/casesReducer'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import AttendanceDataCell from './AttendanceDataCell'
import '_assets/styles/alert-overrides.css'
import dayjs from 'dayjs'

export function Attendance() {
  const { t, i18n } = useTranslation()
  const history = useHistory()
  const dispatch = useDispatch()
  const { reduceTableData } = useCaseData()
  const { makeRequest } = useApiResponse()
  const { cases, token, user } = useSelector(state => ({
    cases: state.cases,
    token: state.auth.token,
    user: state.user
  }))
  const [tableData, setTableData] = useState(cases)
  const [isSuccessModalVisible, setSuccessModalVisibile] = useState(false)
  const [errors, setErrors] = useState(true)
  const reduceAttendanceData = data =>
    data.reduce((acc, cv) => {
      return {
        ...acc,
        ...{
          [cv.id]: [...Array(7).keys()].map(() => ({}))
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
  const removeEmptyString = obj =>
    Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== ''))

  const columnErrorIsPresent = columnIndex =>
    !!Object.values(latestAttendanceData.current).find(
      row => Object.keys(row[columnIndex]).length > 0
    ) && latestColumnDates.current[columnIndex] === ''

  const updateAttendanceData = (updates, record, i) => {
    const newArr = latestAttendanceData.current[record?.id].map(
      (value, index) => {
        // this logic adds and removes fields as needed depending on whether checkin/out or an absence is selected
        return index === i
          ? Object.keys(updates).length === 0 ||
            (Object.keys(value).includes('absence') &&
              (Object.keys(updates).includes('check_in') ||
                Object.keys(updates).includes('check_out'))) ||
            (Object.keys(updates).includes('absence') &&
              (Object.keys(value).includes('check_in') ||
                Object.keys(value).includes('check_out')))
            ? removeEmptyString(updates)
            : removeEmptyString({ ...value, ...updates })
          : value
      }
    )
    latestAttendanceData.current = {
      ...attendanceData,
      [record.id]: newArr
    }
    const errorIsPresent = columnErrorIsPresent(i)

    if (errorIsPresent !== latestError.current) {
      latestError.current = errorIsPresent
      setErrors(errorIsPresent)
      setColumns(generateColumns())
    }
    setAttendanceData(prevData => ({ ...prevData, [record.id]: newArr }))
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
      setColumns(generateColumns())
    }
    setColumnDates(updatedDates)
  }

  const generateColumns = () => {
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
        render: (_, record) => {
          return (
            <AttendanceDataCell
              record={record}
              columnIndex={i}
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
          return (
            <div>
              <p className="mb-1 text-lg">
                {record.childName || record.child.childName}
              </p>
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
    // implemented per: https://help.hotjar.com/hc/en-us/articles/4405109971095-Events-API-Reference
    window.hj =
      window.hj ||
      function () {
        // eslint-disable-next-line no-undef
        ;(hj.q = hj.q || []).push(arguments)
      }
    window.hj('event', 'save_attendance')
    const attendanceBatch = Object.entries(attendanceData).flatMap(data =>
      data[1]
        .map((value, key) => {
          if (Object.keys(value).length === 0) {
            return value
          }

          if (Object.keys(value).includes('absence')) {
            return { ...value, check_in: columnDates[key], child_id: data[0] }
          }

          if (
            Object.keys(value).includes('check_in') &&
            !Object.keys(value).includes('check_out')
          ) {
            return {
              check_in: `${columnDates[key]} ${value.check_in}`,
              child_id: data[0]
            }
          }

          const timeRegex = /(1[0-2]|0?[1-9]):([0-5][0-9]) (am|pm)/
          const parsedCheckIn = value.check_in.match(timeRegex)
          const parsedCheckOut = value.check_out.match(timeRegex)
          const currentDate = dayjs(columnDates[key])
          let checkoutDate

          if (
            (parsedCheckIn[3] === 'am' &&
              parsedCheckOut[3] === 'am' &&
              Number(parsedCheckIn[1]) > Number(parsedCheckOut[1])) ||
            (parsedCheckIn[3] === 'pm' && parsedCheckOut[3] === 'am')
          ) {
            checkoutDate = currentDate.add(1, 'day').format('YYYY-MM-DD')
          } else {
            checkoutDate = currentDate.format('YYYY-MM-DD')
          }

          return {
            check_in: `${columnDates[key]} ${value.check_in}`,
            check_out: `${checkoutDate} ${value.check_out}`,
            child_id: data[0]
          }
        })
        .filter(value => Object.keys(value).length > 0)
    )

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

    if (response.ok) {
      setSuccessModalVisibile(true)
    } else {
      // TODO: handle bad request
      console.log(response, 'bad request')
    }
  }

  useEffect(() => {
    const getCaseData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/case_list_for_dashboard',
        headers: { Authorization: token }
      })

      if (response.ok) {
        const parsedResponse = await response.json()
        const caseData = reduceTableData(parsedResponse, user)
        const reducedAttendanceData = reduceAttendanceData(caseData)

        dispatch(setCaseData(caseData))
        latestAttendanceData.current = reducedAttendanceData
        setAttendanceData(reducedAttendanceData)
        setTableData(caseData)
      }
    }

    if (cases.length === 0) {
      getCaseData()
    }
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
      <Table
        dataSource={tableData.filter(c => c.active)}
        columns={columns}
        bordered={true}
        pagination={false}
        sticky
        scroll={{ x: 1500 }}
        className="my-5"
      />
      <div className="flex justify-center">
        <PaddedButton
          classes="mt-3 w-40"
          text={t('save')}
          onClick={handleSave}
          disabled={latestError.current}
        />
      </div>
      <Modal
        title={<div className="eyebrow-large text-gray9">{t('success')}</div>}
        visible={isSuccessModalVisible}
        onCancel={() => {
          setSuccessModalVisibile(false)
          history.push('/dashboard')
        }}
        footer={[
          <Button
            type="primary"
            key="ok"
            onClick={() => {
              setSuccessModalVisibile(false)
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
