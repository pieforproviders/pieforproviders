import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
  useLocation
} from 'react-router-dom'
import { useSelector } from 'react-redux'
import AuthenticatedRoute from '_utils/_routes/AuthenticatedRoute.js'
import Dashboard from './Dashboard'
import GettingStarted from './GettingStarted'
import Confirmation from './Confirmation'
import NewPassword from './PasswordReset'
import Login from './Login'
import Signup from './Signup'
import NotFound from './NotFound'
import ErrorBoundary from './ErrorBoundary'
import CasesImport from './CasesImport'
import { AuthLayout } from '_shared'
import { useTranslation } from 'react-i18next'
import { useAuthentication } from '_shared/_hooks/useAuthentication'
import runtimeEnv from '@mars/heroku-js-runtime-env'
import TagManager from 'react-gtm-module'

const env = runtimeEnv()

const Routes = () => {
  const { t } = useTranslation()
  const isAuthenticated = useAuthentication()
  const user = useSelector(state => state.user)
  let location = useLocation()

  useEffect(() => {
    const tagManagerArgs = {
      gtmId: env.REACT_APP_GTM_ID,
      auth: env.REACT_APP_GTM_AUTH,
      preview: env.REACT_APP_GTM_PREVIEW,
      dataLayer: {
        userId: user.id
      }
    }

    TagManager.initialize(tagManagerArgs)
  }, [location, user])

  return (
    <div
      id="top"
      className={`text-primaryBlue text-sm h-full ${
        location.pathname === '/signup' || location.pathname === '/login'
          ? 'overflow-hidden'
          : ''
      }`}
    >
      <Switch>
        <Route path="/signup">
          <AuthLayout
            backgroundImageClass="auth-image"
            contentComponent={Signup}
          />
        </Route>
        <Route path="/login">
          <AuthLayout
            backgroundImageClass="auth-image"
            contentComponent={Login}
          />
        </Route>
        <Route path="/password/update">
          <AuthLayout
            backgroundImageClass="auth-image"
            contentComponent={NewPassword}
          />
        </Route>
        <Route
          path="/confirm"
          title="Confirm your Account"
          component={Confirmation}
        />
        <AuthenticatedRoute exact path="/getting-started" title={t('setup')}>
          <GettingStarted />
        </AuthenticatedRoute>
        <AuthenticatedRoute exact path="/dashboard">
          <Dashboard />
        </AuthenticatedRoute>
        <AuthenticatedRoute exact path="/cases/import">
          <CasesImport />
        </AuthenticatedRoute>
        <Route exact path="/">
          <Redirect to={isAuthenticated ? '/dashboard' : '/login'} />
        </Route>
        <Route component={NotFound} />
      </Switch>
    </div>
  )
}

const App = () => {
  return (
    <ErrorBoundary>
      <Router>
        <Routes />
      </Router>
    </ErrorBoundary>
  )
}

export default App
