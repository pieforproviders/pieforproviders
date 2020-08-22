import React from 'react'
import PropTypes from 'prop-types'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Breadcrumb } from 'antd'
import '_assets/styles/layouts.css'
import { useTranslation } from 'react-i18next'

export function LoggedInLayout({ children, title }) {
  const { t } = useTranslation()
  return (
    <>
      <div className="w-full shadow p-4 flex items-center">
        <img
          alt={t('pieforProvidersLogoAltText')}
          src={pieSliceLogo}
          className="w-8 mr-2"
        />
        <div className="text-2xl font-semibold flex-grow">
          Pie for Providers
        </div>
        <div>{t('logout')}</div>
      </div>
      <div className="w-full sm:h-full bg-mediumGray p-4">
        {title && (
          <Breadcrumb className="mb-4">
            <Breadcrumb.Item>{title}</Breadcrumb.Item>
          </Breadcrumb>
        )}
        <div className="bg-white px-4 pb-6 pt-8 shadow rounded-sm">
          {children}
        </div>
      </div>
    </>
  )
}

LoggedInLayout.propTypes = {
  children: PropTypes.element,
  title: PropTypes.string
}
