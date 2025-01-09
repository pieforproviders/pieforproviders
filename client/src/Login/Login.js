import React from 'react'
import { useTranslation } from 'react-i18next'

export function Login() {
  const { t } = useTranslation()

  return (
    <main className="text-center">
      <div className="mb-8">
        <h1 className="h1-large leading-8">{t('gettingStartedWelcome')}</h1>
      </div>
      <div
        style={{ height: '512px' }}
        className="flex items-center justify-center"
      >
        <p className="text-center text-2xl">
          Pie for Providers is not actively operating at this time.
          <br />
          Please reach out with any questions to:
          <br />
          <a
            href="mailto:support@lillio.com"
            className="font-bold no-underline"
          >
            support@lillio.com
          </a>
        </p>
      </div>
    </main>
  )
}
