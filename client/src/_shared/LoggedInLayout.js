import React from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Breadcrumb, Button, Grid } from 'antd'
import '_assets/styles/layouts.css'
import { useTranslation } from 'react-i18next'

const { useBreakpoint } = Grid

export function LoggedInLayout({ children, title }) {
  const { t } = useTranslation()
  const history = useHistory()
  const screens = useBreakpoint()

  const logout = () => {
    localStorage.removeItem('pie-token')
    history.push('/login')
  }

  return (
    <div className="bg-mediumGray">
      <div className="w-full shadow-md p-4 flex items-center bg-white">
        <img
          alt={t('pieforProvidersLogoAltText')}
          src={pieSliceLogo}
          className="w-8 mr-2"
        />
        <div className={`text-2xl font-semibold flex-grow ${screens.lg ? 'visible' : 'invisible'}`}>
          Pie for Providers
        </div>
        <Button type="link" onClick={logout}>
          {t('logout')}
        </Button>
      </div>
      <div className="w-full sm:h-full px-4 mt-4">
        {title && (
          <Breadcrumb className="mb-2">
            <Breadcrumb.Item>{title}</Breadcrumb.Item>
          </Breadcrumb>
        )}
        <div className="bg-white px-4 pb-6 pt-8 shadow-md rounded-sm">
          {children}
        </div>
      </div>
    </div>
  )
}

LoggedInLayout.propTypes = {
  children: PropTypes.element,
  title: PropTypes.string
}
