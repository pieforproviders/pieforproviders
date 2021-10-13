import React from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Checkbox, InputNumber } from 'antd'

export function PaymentModal() {
  const { cases } = useSelector(state => state)
  const { t } = useTranslation()

  const currencyInput = (
    <InputNumber
      defaultValue={1000}
      formatter={value => `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
      parser={value => value.replace(/\$\s?|(,*)/g, '')}
    />
  )

  const table = (
    <table>
      <tr>
        <th>{t('childName')}</th>
        <th>{t('earnedRevenue')}</th>
        <th>
          {t('updatePayment')} ({t('differentPaymentAmount')})
        </th>
      </tr>
      {cases.map(childCase => (
        <tr key={childCase.id}>
          <td>{childCase.childName}</td>
          <td>${childCase.guaranteedRevenue}</td>
          <td>
            <Checkbox /> {t('differentAmountFromState')} {currencyInput}
          </td>
        </tr>
      ))}
    </table>
  )

  return (
    <div>
      <p>{t('recordAChildsPayment')}</p>
      {table}
    </div>
  )
}
