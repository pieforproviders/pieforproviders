import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Button, Divider, Dropdown, Menu } from 'antd'
import { MenuOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { batch, useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'
import { deleteUser } from '_reducers/userReducer'
import { useAuthentication } from '_shared/_hooks/useAuthentication'
import '_assets/styles/button-header.css'

export function Header() {
  const isAuthenticated = useAuthentication()
  const navigate = useNavigate()
  const dispatch = useDispatch()
  const { t, i18n } = useTranslation()
  const [windowWidth, setWindowWidth] = useState(window.innerWidth)
  const setWidth = () => setWindowWidth(window.innerWidth)

  const changeLanguage = lang => i18n.changeLanguage(lang)

  const logout = () => {
    batch(() => {
      dispatch(deleteUser())
      dispatch(removeAuth())
    })
    navigate('/login')
  }

  const renderDesktopMenu = () => (
    <>
      {i18n.language === 'es' ? (
        <Button onClick={() => changeLanguage('en')}>{t('english')}</Button>
      ) : (
        <Button onClick={() => changeLanguage('es')}>{t('spanish')}</Button>
      )}
      {isAuthenticated && (
        <Button type="link" onClick={logout}>
          {t('logout')}
        </Button>
      )}
    </>
  )

  const renderMobileMenu = () => {
    const mobileMenu = (
      <Menu>
        <Menu.Item>
          {isAuthenticated && (
            <Button type="link" onClick={() => navigate('/dashboard')}>
              {t('dashboard')}
            </Button>
          )}
        </Menu.Item>
        <Menu.Item>
          {isAuthenticated && (
            <Button type="link" onClick={() => navigate('/attendnace')}>
              {t('attendance')}
            </Button>
          )}
        </Menu.Item>
        <Divider />
        <Menu.Item>
          {isAuthenticated && (
            <Button type="link" onClick={logout}>
              {t('logout')}
            </Button>
          )}
        </Menu.Item>
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
      </Menu>
    )

    return (
      <Dropdown overlay={mobileMenu}>
        <MenuOutlined />
      </Dropdown>
    )
  }

  // listening for width changes of the window to make the site responsive
  // unfortunately, ant-design breakpoints didn't include 768 <=, but 768 >=
  useEffect(() => {
    window.addEventListener('resize', setWidth)

    return () => window.removeEventListener('resize', setWidth)
  }, [])

  return (
    <header className="w-full shadow-md p-4 flex items-center bg-white">
      <img
        alt={t('pieforProvidersLogoAltText')}
        src={pieSliceLogo}
        className="w-8 mr-2"
      />
      {windowWidth > 768 ? (
        <div className="flex-grow ml-10">
          <div className="flex">
            <div className="header-nav-button">
              <Button
                className="text-lg font-semibold"
                type="link"
                onClick={() => navigate('/dashboard')}
              >
                {t('dashboard')}
              </Button>
            </div>
            <div className="header-nav-button ml-8">
              <Button
                className="text-lg font-semibold"
                type="link"
                onClick={() => navigate('/attendance')}
              >
                {t('attendance')}
              </Button>
            </div>
          </div>
        </div>
      ) : (
        <div className={`text-2xl font-semibold flex-grow`}>
          Pie for Providers
        </div>
      )}
      {windowWidth > 768 ? renderDesktopMenu() : renderMobileMenu()}
    </header>
  )
}
