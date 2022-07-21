import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Alert, Table, Tooltip, Grid, Typography } from 'antd'
import PaymentDataCell from './PaymentDataCell'
import PropTypes from 'prop-types'
import '_assets/styles/payment-table-overrides.css'
import pieSliceLogo from '../_assets/pieSliceLogo.svg'
import { SectionMessage } from '_shared/SectionMessage'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import { ActionLink } from '../_shared/ActionLink'
import { MonthSelector } from '_shared/MonthSelector'
import { useApiService } from '_shared/_hooks/useApiService'

const { useBreakpoint } = Grid
export function PaymentModal({
  setTotalPayment,
  childPayments,
  setChildPayments,
  isFailedPaymentRequest,
  isPaymentSubmitted,
  dates,
  checkIfPaymentRecorded
}) {
  const selectorCases = useSelector(state => state.cases)
  const [cases, setCases] = useState(selectorCases)
  const { t } = useTranslation()
  const [currentChildID, setCurrentChildID] = useState(false)
  const [originalPayments, setOriginalPayments] = useState({})
  const screens = useBreakpoint()
  const isSmallScreen = (screens.sm || screens.xs) && !screens.md
  const [modalDates, setModalDates] = useState({ ...dates })
  const { getChildCases } = useApiService()

  useEffect(() => {
    const fetchCases = async () => {
      const response = await getChildCases(modalDates)
      setCases(response)
      initChildPayments(response)
    }

    fetchCases()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [modalDates])

  function initChildPayments(cases) {
    let payments = {}

    cases.forEach(child => {
      payments[child.id] = child.earnedRevenue
      originalPayments[child.id] = child.earnedRevenue
    })

    console.log('payments', payments)
    setChildPayments(payments)
    setOriginalPayments(payments)
    updateTotalPayments(payments)
  }

  function updateTotalPayments(childPayments) {
    let updatedTotal = Object.values(childPayments).reduce((a, b) => a + b, 0)
    updatedTotal = Math.round(updatedTotal * 100) / 100
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

  const updateSelectedMonth = dates => {
    checkIfPaymentRecorded(dates)
    setModalDates(dates)
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
      <div className="payment-table-text">
        &#36; {childCase.earnedRevenue.toFixed(2)}
      </div>
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
            {`${childCase.child.childFirstName} ${childCase.child.childLastName}`}
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
      title: t('childName'),
      responsive: ['sm'],
      render: childCase => {
        return (
          <div className="payment-table-text">{`${childCase.child.childFirstName} ${childCase.child.childLastName}`}</div>
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

  const paymentSubmittedMessage = (
    <SectionMessage title={t('paymentRecordedMessage')} centered>
      <Typography.Text className="text-sm">
        {t('paymentRecordedHelpMessage')}
      </Typography.Text>
      <ActionLink
        href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}
        text={PIE_FOR_PROVIDERS_EMAIL}
        classes="p-0"
      ></ActionLink>
    </SectionMessage>
  )

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

      <MonthSelector
        dates={modalDates}
        setDates={updateSelectedMonth}
        className={'payment-month-selector text-primaryBlue'}
        size="small"
      />

      <div className="mt-4 mb-2 eyebrow-small">{t('step2')}</div>
      <p className="mb-4 body-1">{t('childrenPayment')}</p>
      {!isPaymentSubmitted ? table : paymentSubmittedMessage}
    </div>
  )
}

PaymentModal.propTypes = {
  setTotalPayment: PropTypes.func.isRequired,
  childPayments: PropTypes.object.isRequired,
  setChildPayments: PropTypes.func.isRequired,
  isFailedPaymentRequest: PropTypes.bool.isRequired,
  isPaymentSubmitted: PropTypes.bool.isRequired,
  dates: PropTypes.object,
  checkIfPaymentRecorded: PropTypes.func
}
