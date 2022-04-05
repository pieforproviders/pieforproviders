/* eslint-disable no-debugger */
import React from 'react'
import { useTranslation } from 'react-i18next'
import pieWithSlice from '../_assets/pieWithSlice.png'

export function ComingSoon() {
  const { t } = useTranslation()

  return (
    <div className="text-center h-full">
      <div>
        <img className="m-auto" alt="pieWithSlice" src={pieWithSlice} />
      </div>
      <h2 className="h2-small mt-6">{t('comingSoonMsg1')}</h2>
      <h2 className="h2-small xs:mt-3 mt-1 mb-5">{t('comingSoonMsg2')}</h2>
    </div>
  )
}
