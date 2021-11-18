import React, { useEffect, useState } from 'react'
import { useHistory } from 'react-router-dom'
import PropTypes from 'prop-types'
import { Button, Grid, Typography, Select } from 'antd'
import { PlusOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/dashboard-overrides.css'

const { useBreakpoint } = Grid
const { Option } = Select

export default function DashboardTitle({ dates, userState, getDashboardData }) {
  const { t } = useTranslation()
  const screens = useBreakpoint()
  const history = useHistory()
  // keeping this dropdown icon logic in hope it can eventually work
  // const [isDropdownVisible, setDropdownVisible] = useState(false)
  // const dropdownStyle = { color: '#006C9E' }
  const [dateFilterValue, setDateFilterValue] = useState(dates.dateFilterValue)

  const matchAndReplaceDate = (dateString = '') => {
    const match = dateString.match(/^[A-Za-z]+/)
    return match ? dateString.replace(match[0], t(match[0].toLowerCase())) : ''
  }

  const renderMonthSelector = () => (
    <Select
      // suffixIcon={
      //   isDropdownVisible ? (
      //     <UpOutlined style={dropdownStyle} />
      //   ) : (
      //     <DownOutlined style={dropdownStyle} />
      //   )
      // }
      // onDropdownVisibleChange={open => setDropdownVisible(open)}
      value={dateFilterValue}
      onChange={value => {
        getDashboardData(value)
        setDateFilterValue(value)
      }}
      size="large"
      className="date-filter-select my-2 text-base mr-2"
    >
      {(dates?.dateFilterMonths ?? []).map((month, k) => (
        <Option key={k} value={month.date}>
          {matchAndReplaceDate(month.displayDate)}
        </Option>
      ))}
    </Select>
  )

  const renderDisabledMonth = () => (
    <Button className="date-filter-button mr-2 text-base py-2 px-4" disabled>
      {matchAndReplaceDate(dates?.dateFilterValue?.displayDate ?? '')}
    </Button>
  )

  useEffect(() => {
    if (!dateFilterValue) {
      setDateFilterValue(dates.dateFilterValue?.date)
    }
  }, [dates, dateFilterValue])

  return (
    <div className="dashboard-title m-2">
      {(screens.sm || screens.xs) && !screens.md ? (
        <div>
          <div className="flex flex-col items-center mb-3">
            <Typography.Title className="dashboard-title text-center mr-4">
              {t('dashboardTitle')}
            </Typography.Title>
            <div className="flex flex-row items-center my-2">
              {userState !== 'NE'
                ? renderMonthSelector()
                : dateFilterValue
                ? renderDisabledMonth()
                : null}
              <Typography.Text className="text-gray3">
                {`${t(`asOf`)}: ${matchAndReplaceDate(dates.asOf)}`}
              </Typography.Text>
            </div>
            <Typography.Text className="mb-3 text-base">
              {t('revenueProjections')}
            </Typography.Text>
            <Button
              className="border-primaryBlue text-primaryBlue flex"
              onClick={() => history.push('/attendance/edit')}
            >
              {t('addAttendance')} <PlusOutlined />
            </Button>
          </div>
        </div>
      ) : (
        <div>
          <div className="flex flex-col items-center mb-3 sm:flex-row">
            <Typography.Title className="dashboard-title text-center mr-4">
              {t('dashboardTitle')}
            </Typography.Title>
            {userState !== 'NE'
              ? renderMonthSelector()
              : dateFilterValue
              ? renderDisabledMonth()
              : null}
            <Typography.Text className="text-gray3">
              {`${t(`asOf`)}: ${matchAndReplaceDate(dates.asOf)}`}
            </Typography.Text>
            <Button
              className="ml-auto border-primaryBlue text-primaryBlue flex"
              onClick={() => history.push('/attendance/edit')}
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
  getDashboardData: PropTypes.func,
  userState: PropTypes.string
}
