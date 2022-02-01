import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Alert, Table, Tooltip, Grid } from 'antd'
import PaymentDataCell from './paymentDataCell'
import PropTypes from 'prop-types'
import '_assets/styles/payment-table-overrides.css'
import pieSliceLogo from '../_assets/pieSliceLogo.svg'

const { useBreakpoint } = Grid

export function PaymentModal({
  setTotalPayment,
  lastMonth,
  childPayments,
  setChildPayments,
  isFailedPaymentRequest
}) {
  const { cases } = useSelector(state => state)
  const { t } = useTranslation()
  const [currentChildID, setCurrentChildID] = useState(false)
  const [originalPayments, setOriginalPayments] = useState({})
  const screens = useBreakpoint()
  const isSmallScreen = (screens.sm || screens.xs) && !screens.md

  useEffect(() => {
    initChildPayments()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    calculateTotalPayments()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [childPayments])

  function initChildPayments() {
    let payments = {}

    cases.forEach(child => {
      payments[child.id] = child.earnedRevenue
      originalPayments[child.id] = child.earnedRevenue
    })

    setChildPayments(payments)
    setOriginalPayments(payments)
  }

  function calculateTotalPayments() {
    const updatedTotal = Object.values(childPayments).reduce((a, b) => a + b, 0)
    setTotalPayment(updatedTotal)
  }

  function updateCurrentRowIndex(childID) {
    setCurrentChildID(childID)
  }

  function updateTotalPayment(value) {
    setChildPayments({ ...childPayments, [currentChildID]: value })
  }

  function resetPayment() {
    updateTotalPayment(originalPayments[currentChildID])
  }

  const earnedRevenueHeader = (
    <div className={isSmallScreen ? 'flex' : ''}>
      <div
        className={'eyebrow-small header-text ' + (isSmallScreen ? 'mr-3' : '')}
      >
        {t('earnedRevenue')}
      </div>
      <div>
        <Tooltip title={t('pieForProvidersHasCalculated')}>
          <span className="calculated-by-text header-text">
            {t('calculatedBy')} Pie
            <img
              alt={t('pieforProvidersLogoAltText')}
              src={pieSliceLogo}
              className="w-5 pie-logo-inline"
            />
          </span>
        </Tooltip>
      </div>
    </div>
  )

  function earnedRevenueBody(childCase) {
    return (
      <div className="payment-table-text">&#36; {childCase.earnedRevenue}</div>
    )
  }

  const childNameHeader = (
    <div className="mb-2 eyebrow-small header-text">{t('childName')}</div>
  )

  const updatePaymentHeader = (
    <div className="eyebrow-small header-text">
      {t('updatePayment')} ({t('differentPaymentAmount')})
    </div>
  )

  const columns = [
    {
      render: childCase => (
        <div>
          <div className="mb-2">
            {childNameHeader}
            {childCase.child.childName}
          </div>
          <div className="mb-2">
            <div className="mb-2 ">{earnedRevenueHeader}</div>
            {earnedRevenueBody(childCase)}
          </div>
          <div>
            <PaymentDataCell
              updateTotalPayment={updateTotalPayment}
              resetPayment={resetPayment}
              isSmallTableSize={true}
            />
          </div>
        </div>
      ),
      responsive: ['xs']
    },
    {
      title: childNameHeader,
      responsive: ['sm'],
      render: childCase => {
        return (
          <div className="payment-table-text">{childCase.child.childName}</div>
        )
      }
    },
    {
      title: earnedRevenueHeader,
      responsive: ['sm'],
      render: childCase => {
        return earnedRevenueBody(childCase)
      }
    },
    {
      title: updatePaymentHeader,
      responsive: ['sm'],
      render: () => (
        <PaymentDataCell
          updateTotalPayment={updateTotalPayment}
          resetPayment={resetPayment}
        />
      )
    }
  ]

  const table = (
    <Table
      id="payment-table flex flex-col"
      bordered={false}
      columns={columns}
      dataSource={cases}
      rowClassName="payment-row"
      pagination={{ hideOnSinglePage: true }}
      onRow={childCase => {
        return {
          onMouseEnter: event => {
            updateCurrentRowIndex(childCase.id)
          }
        }
      }}
    />
  )

  const monthNames = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ]

  const previousMonth = monthNames[lastMonth.getMonth()]
  const previousMonthYear = lastMonth.getFullYear()

  return (
    <div>
      <p className="mb-4 body-1">{t('recordAChildsPayment')}</p>

      {isFailedPaymentRequest ? (
        <Alert
          className="mb-3"
          message={
            <span className="text-base text-gray1">{t('paymentFailed')}</span>
          }
          type="error"
          closable={true}
        />
      ) : (
        <></>
      )}

      <div className="mb-2 eyebrow-small">{t('step1')}</div>
      <p className="mb-2 body-1">{t('choosePaymentMonth')}</p>

      <div className="ml-4">
        {t(previousMonth)} {previousMonthYear}
      </div>

      <div className="mt-4 mb-2 eyebrow-small">{t('step2')}</div>
      <p className="mb-4 body-1">{t('childrenPayment')}</p>
      {table}
    </div>
  )
}

PaymentModal.propTypes = {
  setTotalPayment: PropTypes.func.isRequired,
  lastMonth: PropTypes.instanceOf(Date).isRequired,
  childPayments: PropTypes.object.isRequired,
  setChildPayments: PropTypes.func.isRequired,
  isFailedPaymentRequest: PropTypes.bool.isRequired
}
