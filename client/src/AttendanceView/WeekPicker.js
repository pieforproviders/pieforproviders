import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'
import { LeftOutlined, RightOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'

import dayjs from 'dayjs'
import weekday from 'dayjs/plugin/weekday'

dayjs.extend(weekday)

export function WeekPicker({
  dateSelected,
  handleDateChange,
  hasPrev = true,
  hasNext = true
}) {
  const { t } = useTranslation()
  const firstDay = dateSelected.weekday(0).format('MMM D')
  const lastDay = dateSelected.weekday(6).format('MMM D, YYYY')

  return (
    <div>
      <Button
        disabled={!hasPrev}
        onClick={() => handleDateChange(dateSelected.weekday(-7))}
        data-cy="backWeekButton"
      >
        <LeftOutlined />
      </Button>
      <Button
        className="mx-2"
        style={{
          color: '#1b82ab',
          borderColor: '#1b82ab'
        }}
      >
        {`${t(firstDay.slice(0, 3).toLowerCase())} ${firstDay.slice(3)} - ${t(
          lastDay.slice(0, 3).toLowerCase()
        )}${lastDay.slice(3)}`}
      </Button>
      <Button
        disabled={!hasNext}
        onClick={() => handleDateChange(dateSelected.weekday(7))}
        data-cy="forwardWeekButton"
      >
        <RightOutlined />
      </Button>
    </div>
  )
}

WeekPicker.propTypes = {
  dateSelected: PropTypes.object,
  handleDateChange: PropTypes.func,
  hasPrev: PropTypes.bool,
  hasNext: PropTypes.bool
}
