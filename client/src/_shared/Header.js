import React, { useEffect, useState } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Button, Divider, Dropdown, Menu } from 'antd'
import { MenuOutlined, CloseOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { batch, useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'
import { deleteUser } from '_reducers/userReducer'
import { deleteBusinesses } from '_reducers/businessesReducer'
import { useAuthentication } from '_shared/_hooks/useAuthentication'
import { deleteFilteredCases } from '_reducers/uiReducer'
import '_assets/styles/button-header.css'

export function Header() {
  const isAuthenticated = useAuthentication()
  const dispatch = useDispatch()
  const { t, i18n } = useTranslation()
  const [windowWidth, setWindowWidth] = useState(window.innerWidth)
  const setWidth = () => setWindowWidth(window.innerWidth)
  const history = useHistory()
  const [menuOpen, setMenuOpen] = useState(false)
  let location = useLocation()

  const changeLanguage = lang => i18n.changeLanguage(lang)

  const logout = () => {
    batch(() => {
      dispatch(deleteFilteredCases())
      dispatch(deleteBusinesses())
      dispatch(deleteUser())
      dispatch(removeAuth())
    })
    history.push('/login')
  }

  const renderDesktopMenu = () => (
    <div className="ml-auto">
      {i18n.language === 'es' ? (
        <Button onClick={() => changeLanguage('en')}>{t('english')}</Button>
      ) : (
        <Button className="underline" onClick={() => changeLanguage('es')}>
          {t('spanish')}
        </Button>
      )}
      {isAuthenticated && (
        <Button type="link" onClick={logout}>
          <div className="text-primaryBlue underline hover:text-blue2">
            {t('logout')}
          </div>
        </Button>
      )}
    </div>
  )

  const renderMobileMenu = () => {
    const mobileMenu = (
      <Menu>
        <Menu.Item key="dashboard" className="leading-7">
          {isAuthenticated && (
            <Button
              type="link"
              className="text-lg"
              onClick={() => {
                history.push('/dashboard')
                setMenuOpen(false)
              }}
            >
              <span
                className={
                  location.pathname === '/dashboard' ? 'underline' : ''
                }
                id={'dashboard-tab'}
              >
                {t('dashboard')}
              </span>
            </Button>
          )}
        </Menu.Item>
        <Menu.Item key="attendance" className="leading-7">
          {isAuthenticated && (
            <Button
              type="link"
              className="text-lg"
              onClick={() => {
                history.push('/attendance')
                setMenuOpen(false)
              }}
            >
              <span
                className={
                  location.pathname.includes('/attendance') ? 'underline' : ''
                }
                id={'dashboard-tab'}
              >
                {t('attendance')}
              </span>
            </Button>
          )}
        </Menu.Item>
        <Divider />
        <Menu.Item key="logout" className="leading-7">
          {isAuthenticated && (
            <Button type="link" className="text-lg" onClick={logout}>
              {t('logout')}
            </Button>
          )}
        </Menu.Item>
        {i18n.language === 'es' ? (
          <Menu.Item key="english" className="leading-7">
            <Button
              type="link"
              className="text-lg"
              onClick={() => {
                changeLanguage('en')
                setMenuOpen(false)
              }}
            >
              {t('english')}
            </Button>
          </Menu.Item>
        ) : (
          <Menu.Item key="spanish" className="leading-7">
            <Button
              type="link"
              className="text-lg"
              onClick={() => {
                changeLanguage('es')
                setMenuOpen(false)
              }}
            >
              {t('spanish')}
            </Button>
          </Menu.Item>
        )}
      </Menu>
    )

    return (
      <Dropdown
        className="ml-auto"
        overlay={mobileMenu}
        overlayStyle={{ width: '100%' }}
        trigger="click"
        onVisibleChange={visible => {
          setMenuOpen(visible)
        }}
      >
        {menuOpen ? (
          <CloseOutlined style={{ fontSize: '2rem' }} />
        ) : (
          <MenuOutlined style={{ fontSize: '2rem' }} />
        )}
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
    <header className="flex items-center w-full p-4 bg-white shadow-md">
      <a href="#top">
        <img
          alt={t('pieforProvidersLogoAltText')}
          src={pieSliceLogo}
          className="w-8 mr-2"
          onClick={() => history.push('/dashboard')}
        />
      </a>
      {windowWidth > 768 ? (
        <div className="ml-10 grow">
          <div className="flex">
            <div
              className={`header-nav-button -mb-4 pb-4 ${
                location.pathname === '/dashboard'
                  ? 'border-b-4 border-primaryBlue'
                  : ''
              }`}
            >
              <Button
                className="text-lg font-semibold"
                type="link"
                onClick={() => history.push('/dashboard')}
              >
                {t('dashboard')}
              </Button>
            </div>
            <div
              className={`ml-8 header-nav-button -mb-4 pb-4 ${
                location.pathname.includes('/attendance')
                  ? 'border-b-4 border-primaryBlue'
                  : ''
              }`}
            >
              <Button
                className="text-lg font-semibold"
                type="link"
                onClick={() => history.push('/attendance')}
              >
                {t('attendance')}
              </Button>
            </div>
          </div>
        </div>
      ) : (
        <div className={`text-2xl font-semibold grow`}>Pie for Providers</div>
      )}
      {windowWidth > 768 ? renderDesktopMenu() : renderMobileMenu()}
    </header>
  )
}
