import React from 'react'
import { useTranslation } from 'react-i18next'

export function PaymentModal() {
  const { t } = useTranslation()

  return (
    <div>
      <p>{t('recordAChildsPayment')}</p>
    </div>
  )
}
