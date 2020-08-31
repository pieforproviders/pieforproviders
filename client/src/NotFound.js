import React from 'react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

function NotFound() {
  const { t } = useTranslation()

  return (
    <div className="four-oh-four">
      <h1>{t('notFound')}</h1>
      <Link to="/">{t('goBackHome')}</Link>
    </div>
  )
}

export default NotFound
