import React from 'react'
import { useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Button } from 'antd'
import { Header } from './'
import foodDrinks from '../_assets/foodDrinks.png'

export function ErrorDisplay() {
  const { t } = useTranslation()
  const history = useHistory()

  return (
    <div className="bg-mediumGray h-full min-h-screen">
      <Header />
      <main className="font-semibold w-4/5 py-16 mx-auto sm:flex sm:items-center">
        <article className="text-center sm:text-left sm:w-1/2 sm:pr-16 md:pr-32">
          <h1 className="text-forty sm:text-fortyEight">{t('oops')}</h1>
          <p className="text-fourteen my-6 sm:text-eighteen">{t('notFound')}</p>
          <Button
            type="primary"
            className="font-proxima-nova-alt text-eighteen px-4 py-2 h-auto"
            onClick={() => history.push('/')}
          >
            {t('goBack')}
          </Button>
        </article>
        <figure className="hidden sm:block sm:w-1/2">
          <img src={foodDrinks} alt={t('notFoundImageAltText')} />
        </figure>
      </main>
    </div>
  )
}
