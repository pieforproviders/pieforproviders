import React, { useState } from 'react'
import { Checkbox, InputNumber } from 'antd'
import { useTranslation } from 'react-i18next'
import PropTypes from 'prop-types'

export default function PaymentDataCell({
  updateTotalPayment,
  resetPayment,
  isSmallTableSize = false
}) {
  const { t } = useTranslation()
  const [isDifferentPayment, setIsDifferentPayment] = useState(false)
  const [paymentValue, setPaymentValue] = useState(undefined)

  const currencyInput = (
    <InputNumber
      className={'w-32 ' + (isSmallTableSize ? 'mt-1 ml-4' : 'mr-1')}
      placeholder={t('enterAmount')}
      formatter={value => value.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
      prefix={paymentValue >= 0 ? '$' : ''}
      parser={value => value.replace(/\$\s?|(,*)/g, '')}
      disabled={!isDifferentPayment}
      min={0}
      max={1000000000000}
      value={paymentValue}
      onChange={updatePayment}
    />
  )

  function updatePayment(value) {
    setPaymentValue(value)
    updateTotalPayment(value)
  }

  function resetInput() {
    setPaymentValue(undefined)
  }

  const handleIsDifferentPaymentIsSet = e => {
    const isDifferentPayment = e.target.checked
    setIsDifferentPayment(isDifferentPayment)

    if (!isDifferentPayment) {
      resetPayment()
      resetInput()
    }
  }

  return (
    <div className={isSmallTableSize ? 'flex-col' : 'flex items-center'}>
      <Checkbox className="mr-1" onChange={handleIsDifferentPaymentIsSet} />
      <span className="mr-1"> {t('differentAmountFromState')}</span>
      {currencyInput}
    </div>
  )
}

PaymentDataCell.propTypes = {
  updateTotalPayment: PropTypes.func.isRequired,
  resetPayment: PropTypes.func.isRequired,
  isSmallTableSize: PropTypes.bool
}