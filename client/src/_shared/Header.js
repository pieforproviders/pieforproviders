import React, { useEffect, useState } from 'react'
import { useHistory } from 'react-router-dom'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import { Avatar, Button, Dropdown, Menu, Space } from 'antd'
import { MenuOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import { batch, useDispatch, useSelector } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'
import { deleteUser } from '_reducers/userReducer'
import { useAuthentication } from '_shared/_hooks/useAuthentication'
import '_assets/styles/button-header.css'

export function Header() {
  const isAuthenticated = useAuthentication()
  const dispatch = useDispatch()
  const { t, i18n } = useTranslation()
  const [windowWidth, setWindowWidth] = useState(window.innerWidth)
  const setWidth = () => setWindowWidth(window.innerWidth)
  const history = useHistory()
  const { user } = useSelector(state => ({
    user: state.user
  }))

  const changeLanguage = lang => i18n.changeLanguage(lang)

  const logout = () => {
    batch(() => {
      dispatch(deleteUser())
      dispatch(removeAuth())
    })
    history.push('/login')
  }

  const menu = (
    <Menu>
      <Menu.Item key="profile">
        <Button
          className="text-lg font-semibold"
          type="link"
          onClick={() => history.push('/profile')}
        >
          {t('myProfile')}
        </Button>
      </Menu.Item>
      <Menu.Item key="logout">
        <Button className="text-lg font-semibold" type="link" onClick={logout}>
          {t('logout')}
        </Button>
      </Menu.Item>
    </Menu>
  )

  const renderDesktopMenu = () => (
    <Space size="middle">
      {i18n.language === 'es' ? (
        <Button
          className="border-primaryBlue text-primaryBlue flex"
          onClick={() => changeLanguage('en')}
        >
          {t('english')}
        </Button>
      ) : (
        <Button
          className="border-primaryBlue text-primaryBlue flex"
          onClick={() => changeLanguage('es')}
        >
          {t('spanish')}
        </Button>
      )}
      {isAuthenticated && (
        <Dropdown overlay={menu}>
          <Avatar className="bg-primaryBlue" data-testid="avatar">
            {user.greeting_name && user.greeting_name[0]}
          </Avatar>
        </Dropdown>
      )}
    </Space>
  )

  const renderMobileMenu = () => {
    const mobileMenu = (
      <Menu>
        {isAuthenticated && (
          <>
            <Menu.Item key="dashboard">
              <Button type="link" onClick={() => history.push('/dashboard')}>
                {t('dashboard')}
              </Button>
            </Menu.Item>
            <Menu.Item key="attendance">
              <Button type="link" onClick={() => history.push('/attendance')}>
                {t('attendance')}
              </Button>
            </Menu.Item>
            <Menu.Divider />
            <Menu.Item key="profile">
              <Button type="link" onClick={() => history.push('/profile')}>
                {t('myProfile')}
              </Button>
            </Menu.Item>
            <Menu.Item key="logout">
              <Button type="link" onClick={logout}>
                {t('logout')}
              </Button>
            </Menu.Item>
          </>
        )}
        {i18n.language === 'es' ? (
          <Menu.Item key="english">
            <Button type="link" onClick={() => changeLanguage('en')}>
              {t('english')}
            </Button>
          </Menu.Item>
        ) : (
          <Menu.Item key="spanish">
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
                onClick={() => history.push('/dashboard')}
              >
                {t('dashboard')}
              </Button>
            </div>
            <div className="header-nav-button ml-8">
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
        <div className={`text-2xl font-semibold flex-grow`}>
          Pie for Providers
        </div>
      )}
      {windowWidth > 768 ? renderDesktopMenu() : renderMobileMenu()}
    </header>
  )
}
