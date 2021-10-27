import React, { useState } from 'react'
import { Checkbox, InputNumber } from 'antd'
import { useTranslation } from 'react-i18next'
import PropTypes from 'prop-types'

export default function PaymentDataCell({ updateTotalPayment }) {
  const { t } = useTranslation()
  const [isDifferentPayment, setIsDifferentPayment] = useState(false)

  const currencyInput = (
    <InputNumber
      className="w-32"
      placeholder={t('enterAmount')}
      formatter={value => inputFormatter(value)}
      parser={value => value.replace(/\$\s?|(,*)/g, '')}
      disabled={!isDifferentPayment}
      onChange={updatePayment}
    />
  )

  function inputFormatter(value) {
    if (!isDifferentPayment) {
      return null
    }

    return `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  }

  function updatePayment(value) {
    updateTotalPayment(value)
  }

  const handleIsDifferentPaymentIsSet = e => {
    setIsDifferentPayment(e.target.checked)
  }

  return (
    <div className="flex items-center">
      <Checkbox className="mr-1" onChange={handleIsDifferentPaymentIsSet} />
      <span className="mr-1"> {t('differentAmountFromState')}</span>
      {currencyInput}
    </div>
  )
}

PaymentDataCell.propTypes = {
  updateTotalPayment: PropTypes.func.isRequired
}
