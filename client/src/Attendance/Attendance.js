import React from 'react'
import { Alert, Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import '_assets/styles/alert-overrides.css'

export function Attendance() {
  const { t } = useTranslation()
  const cases = useSelector(state => state.cases)
  console.log(cases)
  // eslint-disable-next-line no-debugger
  debugger
  return (
    <div className="flex justify-center items-center flex-col flex-nowrap">
      <p className="h1-large mb-4">{t('enterAttendance')}</p>
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
        <Table className="my-5"></Table>
      </p>
    </div>
  )
}
