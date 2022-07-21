import React from 'react'
import { Select } from 'antd'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import getFormattedMonthYearDate from '_utils/dateFormatter'

const { Option } = Select

export function MonthSelector({
  dates,
  setDates,
  onChange,
  className,
  size = 'large'
}) {
  const { t } = useTranslation()
  const { sendGAEvent } = useGoogleAnalytics()
  const matchAndReplaceDate = (dateString = '') => {
    const match = dateString.match(/^[A-Za-z]+/)
    return match ? dateString.replace(match[0], t(match[0].toLowerCase())) : ''
  }

  return (
    <Select
      value={dates?.dateFilterValue?.date}
      onChange={value => {
        sendGAEvent('dates_filtered', {
          page_title: 'dashboard',
          date_selected: value.slice(0, 7)
        })
        setDates({
          ...dates,
          dateFilterValue: getFormattedMonthYearDate(new Date(value))
        })
        if (onChange) {
          onChange(value)
        }
      }}
      size={size}
      className={className}
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
}

MonthSelector.propTypes = {
  dates: PropTypes.object,
  setDates: PropTypes.func,
  onChange: PropTypes.func,
  className: PropTypes.string,
  size: PropTypes.string
}
