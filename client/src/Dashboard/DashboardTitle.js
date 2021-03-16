import React, { useEffect, useState } from 'react'
import PropTypes from 'prop-types'
import { Button, Typography, Select } from 'antd'
import { DownOutlined, UpOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/dashboard-overrides.css'

const { Option } = Select

export default function DashboardTitle({ dates, userState, getDashboardData }) {
  const { t } = useTranslation()
  const [isDropdownVisible, setDropdownVisible] = useState(false)
  const [dateFilterValue, setDateFilterValue] = useState(dates.dateFilterValue)
  const dropdownStyle = { color: '#006C9E' }

  const matchAndReplaceDate = (dateString = '') => {
    const match = dateString.match(/^[A-Za-z]+/)
    return match ? dateString.replace(match[0], t(match[0].toLowerCase())) : ''
  }

  useEffect(() => {
    if (!dateFilterValue) {
      setDateFilterValue(dates.dateFilterValue?.date)
    }
  }, [dates, dateFilterValue])

  return (
    <div className="dashboard-title m-2">
      <div className="flex items-center mb-3">
        <Typography.Title className="dashboard-title mr-4">
          {t('dashboardTitle')}
        </Typography.Title>
        {userState !== 'NE' ? (
          <Select
            suffixIcon={
              isDropdownVisible ? (
                <UpOutlined style={dropdownStyle} />
              ) : (
                <DownOutlined style={dropdownStyle} />
              )
            }
            value={dateFilterValue}
            onDropdownVisibleChange={open => setDropdownVisible(open)}
            onChange={value => {
              getDashboardData(value)
              setDateFilterValue(value)
            }}
            size="large"
            className="date-filter-select mr-2 text-base"
          >
            {(dates?.dateFilterMonths ?? []).map((month, k) => (
              <Option key={k} value={month.date}>
                {matchAndReplaceDate(month.displayDate)}
              </Option>
            ))}
          </Select>
        ) : dateFilterValue ? (
          <Button
            className="date-filter-button mr-2 text-base py-2 px-4"
            disabled
          >
            {matchAndReplaceDate(dates?.dateFilterValue?.displayDate ?? '')}
          </Button>
        ) : null}
        <Typography.Text className="text-gray3">
          {`${t(`asOf`)}: ${matchAndReplaceDate(dates.asOf)}`}
        </Typography.Text>
      </div>
      <Typography.Text className="md-3 text-base">
        {t('revenueProjections')}
      </Typography.Text>
    </div>
  )
}

DashboardTitle.propTypes = {
  dates: PropTypes.object,
  getDashboardData: PropTypes.func,
  userState: PropTypes.string
}
