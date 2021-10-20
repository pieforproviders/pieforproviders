import React, { useState } from 'react'
import { Checkbox, InputNumber } from 'antd'
import { useTranslation } from 'react-i18next'
import PropTypes from 'prop-types'

export default function PaymentDataCell({ updateTotalPayment }) {
  const { t } = useTranslation()
  const [isDifferentPayment, setIsDifferentPayment] = useState(false)

  const currencyInput = (
    <InputNumber
      placeholder={t('enterAmount')}
      formatter={value => `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
      parser={value => value.replace(/\$\s?|(,*)/g, '')}
      disabled={!isDifferentPayment}
      onChange={test}
    />
  )

  function test(value) {
    updateTotalPayment(value)
  }

  const handleIsDifferentPaymentIsSet = e => {
    setIsDifferentPayment(e.target.checked)
  }

  return (
    <div>
      <Checkbox onChange={handleIsDifferentPaymentIsSet} />
      {t('differentAmountFromState')} {currencyInput}
    </div>
  )
}

PaymentDataCell.propTypes = {
  updateTotalPayment: PropTypes.func.isRequired
}
