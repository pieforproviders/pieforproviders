import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Alert, Table, Tooltip } from 'antd'
import PaymentDataCell from './paymentDataCell'
import PropTypes from 'prop-types'
import '_assets/styles/payment-table-overrides.css'
import pieSliceLogo from '../_assets/pieSliceLogo.svg'

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
    <div>
      {t('earnedRevenue')}
      <div>
        <Tooltip title={t('pieForProvidersHasCalculated')}>
          <span className="calculated-by-text">
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

  const columns = [
    {
      title: t('childName'),
      render: childCase => {
        return (
          <div className="payment-table-text">{childCase.child.childName}</div>
        )
      }
    },
    {
      title: earnedRevenueHeader,
      render: childCase => {
        return (
          <div className="payment-table-text">${childCase.earnedRevenue}</div>
        )
      }
    },
    {
      title: updatePaymentHeader,
      render: () => (
        <PaymentDataCell
          updateTotalPayment={updateTotalPayment}
          resetPayment={resetPayment}
        />
      )
    }
  ]

  function updatePaymentHeader() {
    return (
      <div>
        {t('updatePayment')} ({t('differentPaymentAmount')})
      </div>
    )
  }

  const table = (
    <Table
      id="payment-table"
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
