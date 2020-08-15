import React from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import { Select } from 'antd'
import pieFullTanLogo from '_assets/pieFullTanLogo.svg'
import '_assets/styles/layouts.css'

const { Option } = Select

export function AuthLayout({
  backgroundImageClass,
  contentComponent: ContentComponent
}) {
  const { t, i18n } = useTranslation()

  return (
    <div className="grid grid-cols-1 medium:grid-cols-8 large:grid-cols-2 h-screen">
      <div
        className={`hidden large:block h-screen block bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <div className="w-full medium:col-span-8 large:col-auto px-4 medium:px-8 overflow-y-scroll mt-8">
        <div className="flex flex-col">
          <Select
            value={i18n.language}
            onChange={language => i18n.changeLanguage(language)}
            className="self-end"
            bordered={false}
          >
            <Option value="en">{t('english')}</Option>
            <Option value="es">{t('spanish')}</Option>
          </Select>
        </div>
        <div className="text-center large:text-left large:col-span-3 medium:grid medium:grid-cols-8 large:grid-cols-6">
          <div className="medium:col-start-3 medium:col-span-4 large:col-span-4">
            <img
              alt={t('pieforProvidersLogoAltText')}
              src={pieFullTanLogo}
              className="w-24 medium:w-48 mt-0 mb-8 medium:mb-16 large:mb-12 mx-auto"
            />
            <ContentComponent />
          </div>
        </div>
      </div>
    </div>
  )
}

AuthLayout.propTypes = {
  backgroundImageClass: PropTypes.string,
  contentComponent: PropTypes.func
}
