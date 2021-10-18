import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { Table } from 'antd'
import PaymentDataCell from './paymentDataCell'

export function PaymentModal() {
  const { cases } = useSelector(state => state)
  const { t } = useTranslation()
  const [childPayments] = useState(false)

  function initChildPayments() {
    cases.forEach(child => {
      childPayments.push(child.guaranteedRevenue)
    })
  }

  initChildPayments()

  // const table = (
  //   <table>
  //     <thead>
  //       <tr>
  //         <th>{t('childName')}</th>
  //         <th>{t('earnedRevenue')}</th>
  //         <th>
  //           {t('updatePayment')} ({t('differentPaymentAmount')})
  //         </th>
  //       </tr>
  //     </thead>
  //     <tbody>
  //       {cases.map(childCase => (
  //         <tr key={childCase.id}>
  //           <td>{childCase.childName}</td>
  //           <td>${childCase.guaranteedRevenue}</td>
  //           <td>
  //             <Checkbox /> {t('differentAmountFromState')} {currencyInput()}
  //           </td>
  //         </tr>
  //       ))}
  //     </tbody>
  //   </table>
  // )

  const updateTotalPayment = (value, index) => {
    childPayments[index] = value
    console.log(childPayments)
  }

  const columns = [
    {
      title: t('childName'),
      dataIndex: 'childName'
    },
    {
      title: t('earnedRevenue'),
      dataIndex: 'guaranteedRevenue'
    },
    {
      title: updatePaymentHeader,
      render: index => {
        return (
          <PaymentDataCell
            updateTotalPayment={updateTotalPayment}
            columnIndex={index}
          />
        )
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

  const table = <Table bordered={false} columns={columns} dataSource={cases} />

  return (
    <div>
      <p>{t('recordAChildsPayment')}</p>
      {table}
    </div>
  )
}
