import React, { useState, useEffect } from 'react'
import { useHistory } from 'react-router-dom'
import PropTypes from 'prop-types'
import { Button, Grid, Typography, Select, Menu, Dropdown, Modal } from 'antd'
import { LeftOutlined, DownOutlined, CloseOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import '_assets/styles/dashboard-overrides.css'
import '_assets/styles/payment-table-overrides.css'
import PaymentModal from '../Payment'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'

const { useBreakpoint } = Grid
const { Option } = Select

export default function DashboardTitle({ dates, setDates, makeMonth }) {
  const { t } = useTranslation()
  const { sendGAEvent } = useGoogleAnalytics()
  const screens = useBreakpoint()
  const history = useHistory()
  // keeping this dropdown icon logic in hope it can eventually work
  // const [isDropdownVisible, setDropdownVisible] = useState(false)
  // const dropdownStyle = { color: '#006C9E' }
  const [dateFilterValue, setDateFilterValue] = useState(dates.dateFilterValue)
  const [isPaymentModalVisible, setPaymentModalVisible] = useState(false)
  const [isActionsDropdownOpen, setActionsDropdownOpen] = useState(false)
  const [totalPayment, setTotalPayment] = useState(0)
  const [childPayments, setChildPayments] = useState({})
  const [isPaymentSuccessOpen, setPaymentSuccessOpen] = useState(false)
  const { makeRequest } = useApiResponse()
  const [isFailedPaymentRequest, setIsFailedPaymentRequest] = useState(false)
  const { token } = useSelector(state => ({ token: state.auth.token }))
  const matchAndReplaceDate = (dateString = '') => {
    const match = dateString.match(/^[A-Za-z]+/)
    return match ? dateString.replace(match[0], t(match[0].toLowerCase())) : ''
  }
  const lastMonth = new Date()
  lastMonth.setMonth(lastMonth.getMonth() - 1)
  const renderMonthSelector = () => (
    <Select
      value={dates?.dateFilterValue?.date}
      onChange={value => {
        sendGAEvent('dates_filtered', {
          page_title: 'dashboard',
          date_selected: value.slice(0, 7)
        })
        setDates({
          ...dates,
          dateFilterValue: makeMonth(new Date(value))
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
        <Button
          onClick={() => {
            sendGAEvent('attendance_input_clicked', {
              page_title: 'dashboard'
            })

            history.push('/attendance/edit')
          }}
          type="text"
        >
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
      className="flex ml-auto"
      trigger="click"
    >
      <Button
        type="primary"
        id="actionsDropdownButton"
        name="recordNew"
        onClick={updateIsActionsDropdownOpen}
      >
        {t('recordDropdown')}
        {isActionsDropdownOpen ? <DownOutlined /> : <LeftOutlined />}
      </Button>
    </Dropdown>
  )

  const addPayment = async () => {
    const paymentsBatch = Object.entries(childPayments).flatMap(data => {
      return {
        month: lastMonth.toISOString().split('T')[0],
        amount: data[1],
        child_id: data[0]
      }
    })

    const response = await makeRequest({
      type: 'post',
      url: '/api/v1/payments_batches',
      headers: {
        Authorization: token
      },
      data: {
        payments_batch: paymentsBatch
      }
    })

    if (response.ok) {
      setPaymentModalVisible(false)
      setIsFailedPaymentRequest(false)
      setPaymentSuccessOpen(true)
      return
    }

    setIsFailedPaymentRequest(true)
  }
  const paymentModal = (
    <Modal
      className="payment-modal"
      title={<div className="text-center h2-large">{t('recordAPayment')}</div>}
      closeIcon={<CloseOutlined className="-btn-primary" />}
      visible={isPaymentModalVisible}
      onCancel={handlePaymentModalCancel}
      destroyOnClose={true}
      //todo determine width. Maybe 50% of screen size
      width={1000}
      footer={
        <div className="flex justify-center">
          <Button
            type="primary"
            shape="round"
            size="large"
            className="record-payment-button"
            onClick={addPayment}
          >
            {t('recordPaymentOf')} ${totalPayment.toFixed()}
          </Button>
        </div>
      }
    >
      <PaymentModal
        setTotalPayment={setTotalPayment}
        lastMonth={lastMonth}
        childPayments={childPayments}
        setChildPayments={setChildPayments}
        isFailedPaymentRequest={isFailedPaymentRequest}
      />
    </Modal>
  )

  useEffect(() => {
    if (!dateFilterValue) {
      setDateFilterValue(dates.dateFilterValue?.date)
    }
  }, [dates, dateFilterValue])

  const monthNames = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december'
  ]

  const previousMonth = monthNames[lastMonth.getMonth()]
  const previousMonthYear = lastMonth.getFullYear()

  const handleOk = () => {
    setPaymentSuccessOpen(false)
  }

  const paymentSuccessModal = (
    <Modal
      className="payment-success-modal"
      title={<div className="text-center h2-large">{t('paymentSuccess')}</div>}
      closeIcon={<CloseOutlined className="-btn-primary" />}
      visible={isPaymentSuccessOpen}
      onOk={handleOk}
      onCancel={handleOk}
      footer={
        <div className="flex justify-end">
          <Button
            type="primary"
            shape="round"
            size="large"
            className="payment-success-button"
            onClick={handleOk}
          >
            {t('okButton')}
          </Button>
        </div>
      }
    >
      <p>
        {t('paymentSuccessText')} {t(previousMonth)} {previousMonthYear}{' '}
        {t('paymentSuccessText2')} <b>${totalPayment.toFixed()}.</b>
      </p>
    </Modal>
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

            {dashboardActionDropdown}
          </div>

          {paymentModal}
          {paymentSuccessModal}
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

            {dashboardActionDropdown}
          </div>
          <Typography.Text className="text-base">
            {t('revenueProjections')}
          </Typography.Text>

          {paymentModal}
          {paymentSuccessModal}
        </div>
      )}
    </div>
  )
}

DashboardTitle.propTypes = {
  dates: PropTypes.object,
  setDates: PropTypes.func,
  makeMonth: PropTypes.func
}
