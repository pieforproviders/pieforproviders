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

export function Attendance() {
  const { t } = useTranslation()
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
  const [columnDates, setColumnDates] = useState(
    [...Array(7).keys()].map(() => '')
  )
  const latestAttendanceData = useRef(attendanceData)
  const latestColumnDates = useRef(columnDates)

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
            ? updates
            : { ...value, ...updates }
          : value
      }
    )
    latestAttendanceData.current = {
      ...attendanceData,
      [record.id]: newArr
    }
    setAttendanceData(prevData => ({ ...prevData, [record.id]: newArr }))
  }

  const handleDateChange = (index, ds) => {
    const updatedDates = latestColumnDates.current.map((value, i) =>
      index === i ? ds : value
    )
    latestColumnDates.current = updatedDates
    setColumnDates(updatedDates)
  }

  const [columns] = useState(() => {
    let cols = []
    for (let i = 0; i < 7; i++) {
      cols.push({
        dataIndex: 'date' + i,
        key: 'date' + i,
        width: 398,
        // eslint-disable-next-line react/display-name
        title: () => (
          <DatePicker
            disabledDate={c => c && c.valueOf() > Date.now()}
            onChange={(_, ds) => handleDateChange(i, ds)}
            bordered={false}
          />
        ),
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
        title: 'Child Name',
        dataIndex: 'name',
        width: 250,
        key: 'name',
        // eslint-disable-next-line react/display-name
        render: (_, record) => {
          return (
            <div>
              <p className="text-lg mb-1">
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
  })

  const handleSave = async () => {
    const attendanceBatch = Object.entries(attendanceData).flatMap(cv =>
      cv[1]
        .filter(v => Object.keys(v).length > 0)
        .map((v, k) =>
          Object.keys(v).includes('absence')
            ? { ...v, check_in: columnDates[k], child_id: cv[0] }
            : {
                check_in: `${columnDates[k]} ${v.check_in}`,
                check_out: `${columnDates[k]} ${v.check_out}`,
                child_id: cv[0]
              }
        )
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
        dispatch(setCaseData(caseData))
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
          dataSource={tableData.filter(c => c.active)}
          columns={columns}
          bordered={true}
          pagination={false}
          sticky
          scroll={{ x: 1500 }}
          className="my-5"
        ></Table>
      </p>
      <div className="flex justify-center">
        <PaddedButton classes="mt-3 w-40" text={'Save'} onClick={handleSave} />
      </div>
      <Modal
        title={<div className="eyebrow-large text-gray9">Success!</div>}
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
            Go to dashboard
          </Button>
        ]}
      >
        <p>
          You just entered some attendance history for the children in your
          care.
        </p>
      </Modal>
    </div>
  )
}
