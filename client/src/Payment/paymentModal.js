import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Table, Tooltip } from 'antd'
import PaymentDataCell from './paymentDataCell'
import PropTypes from 'prop-types'
import '_assets/styles/payment-table-overrides.css'
import pieSliceLogo from '../_assets/pieSliceLogo.svg'

export function PaymentModal({
  setTotalPayment,
  lastMonth,
  childPayments,
  setChildPayments
}) {
  const { cases } = useSelector(state => state)
  const { t } = useTranslation()
  const [currentChildID, setCurrentChildID] = useState(false)

  useEffect(() => {
    initChildPayments()
  }, [])

  useEffect(() => {
    calculateTotalPayments()
  }, [childPayments])

  function initChildPayments() {
    let payments = {}

    cases.forEach(child => {
      payments[child.id] = child.guaranteedRevenue
    })
    setChildPayments(payments)
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
        return <div className="payment-table-text"> {childCase.childName} </div>
      }
    },
    {
      title: earnedRevenueHeader,
      render: childCase => {
        return (
          <div className="payment-table-text">
            ${childCase.guaranteedRevenue}
          </div>
        )
      }
    },
    {
      title: updatePaymentHeader,
      render: () => {
        return <PaymentDataCell updateTotalPayment={updateTotalPayment} />
      }
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
      <div className="mb-2 eyebrow-small">{t('step1')}</div>
      <p className="mb-2 body-1">{t('choosePaymentMonth')}</p>

      <span className="ml-4">
        {t(previousMonth)} {previousMonthYear}
      </span>

      <div className="mt-4 mb-2 eyebrow-small">{t('step2')}</div>
      <p className="mb-4 body-1">{t('childrenPayment')}</p>
      {table}
    </div>
  )
}

PaymentModal.propTypes = {
  setTotalPayment: PropTypes.func.isRequired,
  lastMonth: PropTypes.instanceOf(Date).isRequired,
  childPayments: PropTypes.array.isRequired,
  setChildPayments: PropTypes.func.isRequired
}
