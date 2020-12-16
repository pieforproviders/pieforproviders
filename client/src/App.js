import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
  useLocation
} from 'react-router-dom'
import AuthenticatedRoute from '_utils/_routes/AuthenticatedRoute.js'
import ReactGA from 'react-ga'
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

const Routes = () => {
  const { t } = useTranslation()
  const isAuthenticated = useAuthentication()
  let location = useLocation()

  return (
    <div
      className={`text-primaryBlue font-proxima text-sm h-full ${
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
  useEffect(() => {
    /* skip production code for coverage */
    /* istanbul ignore next */
    if (process.env.NODE_ENV === 'production') {
      ReactGA.initialize('UA-117297491-1')
    }
  }, [])

  return (
    <ErrorBoundary>
      <Router>
        <Routes />
      </Router>
    </ErrorBoundary>
  )
}

export default App
