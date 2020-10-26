import React from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Breadcrumb, Button, Dropdown, Grid, Menu } from 'antd'
import { MenuOutlined } from '@ant-design/icons'
import '_assets/styles/layouts.css'
import { useTranslation } from 'react-i18next'
import { useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'

const { useBreakpoint } = Grid

export function LoggedInLayout({ children, title }) {
  const dispatch = useDispatch()
  const { t, i18n } = useTranslation()
  const history = useHistory()
  const screens = useBreakpoint()

  const logout = () => {
    dispatch(removeAuth())
    history.push('/login')
  }

  const changeLanguage = lang => i18n.changeLanguage(lang)

  const mobileMenu = (
    <Menu>
      {i18n.language === 'es' ? (
        <Menu.Item>
          <Button type="link" onClick={() => changeLanguage('en')}>
            {t('english')}
          </Button>
        </Menu.Item>
      ) : (
        <Menu.Item>
          <Button type="link" onClick={() => changeLanguage('es')}>
            {t('spanish')}
          </Button>
        </Menu.Item>
      )}
      <Menu.Item>
        <Button type="link" onClick={logout}>
          {t('logout')}
        </Button>
      </Menu.Item>
    </Menu>
  )

  return (
    <div className="bg-mediumGray">
      <div className="w-full shadow-md p-4 flex items-center bg-white">
        <img
          alt={t('pieforProvidersLogoAltText')}
          src={pieSliceLogo}
          className="w-8 mr-2"
        />
        <div
          className={`text-2xl font-semibold flex-grow ${
            screens.lg ? 'visible' : 'invisible'
          }`}
        >
          Pie for Providers
        </div>
        {screens.md ? (
          <>
            {i18n.language === 'es' ? (
              <Button onClick={() => changeLanguage('en')}>
                {t('english')}
              </Button>
            ) : (
              <Button onClick={() => changeLanguage('es')}>
                {t('spanish')}
              </Button>
            )}
            <Button type="link" onClick={logout}>
              {t('logout')}
            </Button>
          </>
        ) : (
          <Dropdown overlay={mobileMenu}>
            <MenuOutlined />
          </Dropdown>
        )}
      </div>
      <div className="w-full xs:h-full px-4 mt-4">
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
