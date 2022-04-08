import React from 'react'
import { useTranslation } from 'react-i18next'
import pieWithSlice from '../_assets/pieWithSlice.png'

export function ComingSoon() {
  const { t } = useTranslation()

  return (
    <div className="h-full text-center">
      <div>
        <img className="m-auto" alt="pieWithSlice" src={pieWithSlice} />
      </div>
      <h2 className="mt-6 h2-small">{t('comingSoonMsg1')}</h2>
      <h2 className="mt-1 mb-5 h2-small xs:mt-3">{t('comingSoonMsg2')}</h2>
    </div>
  )
}
