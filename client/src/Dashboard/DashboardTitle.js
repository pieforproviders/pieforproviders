import React from 'react'
import { useHistory } from 'react-router-dom'
import PropTypes from 'prop-types'
import { Button, Grid, Typography, Select } from 'antd'
import { PlusOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import '_assets/styles/dashboard-overrides.css'

const { useBreakpoint } = Grid
const { Option } = Select

export default function DashboardTitle({ dates, setDates }) {
  const { t } = useTranslation()
  const { sendGAEvent } = useGoogleAnalytics()
  const screens = useBreakpoint()
  const history = useHistory()

  const matchAndReplaceDate = (dateString = '') => {
    const match = dateString.match(/^[A-Za-z]+/)
    return match ? dateString.replace(match[0], t(match[0].toLowerCase())) : ''
  }

  const renderMonthSelector = () => (
    <Select
      value={dates.dateFilterValue.date}
      onChange={value => {
        sendGAEvent('dates_filtered', {
          page_title: 'dashboard',
          date_selected: value
        })
        setDates({
          ...dates,
          dateFilterValue: { displayDate: value, date: value }
        })
      }}
      size="large"
      className="my-2 mr-2 text-base date-filter-select"
    >
      {(dates?.dateFilterMonths ?? []).map((month, k) => {
        return (
          <Option key={k} value={month.date}>
            {matchAndReplaceDate(month.displayDate)}
          </Option>
        )
      })}
    </Select>
  )

  return (
    <div className="m-2 dashboard-title">
      {(screens.sm || screens.xs) && !screens.md ? (
        <div>
          <div className="flex flex-col items-center mb-3">
            <Typography.Title className="mr-4 text-center dashboard-title">
              {t('dashboardTitle')}
            </Typography.Title>
            <div className="flex flex-row items-center my-2">
              {renderMonthSelector()}
              <Typography.Text className="text-gray3">
                {`${t(`asOf`)}: ${matchAndReplaceDate(dates.asOf)}`}
              </Typography.Text>
            </div>
            <Typography.Text className="mb-3 text-base">
              {t('revenueProjections')}
            </Typography.Text>
            <Button
              className="flex border-primaryBlue text-primaryBlue"
              onClick={() => {
                sendGAEvent('attendance_input_clicked', {
                  page_title: 'dashboard'
                })

                history.push('/attendance/edit')
              }}
            >
              {t('addAttendance')} <PlusOutlined />
            </Button>
          </div>
        </div>
      ) : (
        <div>
          <div className="flex flex-col items-center mb-3 sm:flex-row">
            <Typography.Title className="mr-4 text-center dashboard-title">
              {t('dashboardTitle')}
            </Typography.Title>
            {renderMonthSelector()}
            <Typography.Text className="text-gray3">
              {`${t(`asOf`)}: ${matchAndReplaceDate(dates.asOf)}`}
            </Typography.Text>
            <Button
              className="flex ml-auto border-primaryBlue text-primaryBlue"
              onClick={() => {
                sendGAEvent('attendance_input_clicked', {
                  page_title: 'dashboard'
                })

                history.push('/attendance/edit')
              }}
            >
              {t('addAttendance')} <PlusOutlined />
            </Button>
          </div>
          <Typography.Text className="text-base">
            {t('revenueProjections')}
          </Typography.Text>
        </div>
      )}
    </div>
  )
}

DashboardTitle.propTypes = {
  dates: PropTypes.object,
  setDates: PropTypes.func
}
