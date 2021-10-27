import React, { useEffect, useState } from 'react'
import { useHistory } from 'react-router-dom'
import PropTypes from 'prop-types'
import { Button, Grid, Typography, Select, Menu, Dropdown, Modal } from 'antd'
import { LeftOutlined, DownOutlined, CloseOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/dashboard-overrides.css'
import '_assets/styles/payment-table-overrides.css'
import PaymentModal from '../Payment'

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
  const [isPaymentModalVisible, setPaymentModalVisible] = useState(false)
  const [isActionsDropdownOpen, setActionsDropdownOpen] = useState(false)
  const [totalPayment, setTotalPayment] = useState(0)

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

  const showPaymentModal = () => {
    setPaymentModalVisible(true)
  }

  const handlePaymentModalCancel = () => {
    setPaymentModalVisible(false)
  }

  const updateIsActionsDropdownOpen = () => {
    setActionsDropdownOpen(!isActionsDropdownOpen)
  }

  const dashboardActions = (
    <Menu>
      <Menu.Item key="addAttendanceMenuItem">
        <Button onClick={() => history.push('/attendance/edit')} type="text">
          {t('addAttendance')}
        </Button>
      </Menu.Item>
      <Menu.Item key="recordPaymentMenuItem">
        <Button id="recordPaymentButton" type="text" onClick={showPaymentModal}>
          {t('recordPaymentButton')}
        </Button>
      </Menu.Item>
    </Menu>
  )

  const dashboardActionDropdown = (
    <Dropdown
      overlay={dashboardActions}
      className="ml-auto flex"
      trigger="click"
    >
      <Button
        type="primary"
        id="actionsDropdownButton"
        onClick={updateIsActionsDropdownOpen}
      >
        {t('recordDropdown')}
        {isActionsDropdownOpen ? <DownOutlined /> : <LeftOutlined />}
      </Button>
    </Dropdown>
  )

  const paymentModal = (
    <Modal
      title={
        <div className="eyebrow-large text-center">{t('recordAPayment')}</div>
      }
      closeIcon={<CloseOutlined className="-btn-primary" />}
      visible={isPaymentModalVisible}
      onCancel={handlePaymentModalCancel}
      //todo determine width. Maybe 50% of screen size
      width={1000}
      footer={
        <div className="flex justify-center">
          <Button
            type="primary"
            shape="round"
            size="large"
            className="record-payment-button"
          >
            {t('recordPaymentOf')} ${totalPayment.toFixed()}
          </Button>
        </div>
      }
    >
      <PaymentModal setTotalPayment={setTotalPayment} />
    </Modal>
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

            {dashboardActionDropdown}
          </div>

          {paymentModal}
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

            {dashboardActionDropdown}
          </div>
          <Typography.Text className="text-base">
            {t('revenueProjections')}
          </Typography.Text>

          {paymentModal}
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
