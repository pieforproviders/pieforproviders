import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
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
import useAuthentication from '_shared/_hooks/useAuthentication'

const App = () => {
  const { t } = useTranslation()

  const { isAuthenticated } = useAuthentication()

  useEffect(() => {
    /* skip production code for coverage */
    /* istanbul ignore next */
    if (process.env.NODE_ENV === 'production') {
      ReactGA.initialize('UA-117297491-1')
    }
  }, [])

  return (
    <div className="text-primaryBlue font-proxima text-sm h-screen">
      <ErrorBoundary>
        <Router>
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
              title={t('confirmYourAccount')}
              component={Confirmation}
            />
            <AuthenticatedRoute
              exact
              path="/getting-started"
              title={t('setup')}
              contentComponent={GettingStarted}
            />
            <AuthenticatedRoute
              exact
              path="/dashboard"
              contentComponent={Dashboard}
            />
            <AuthenticatedRoute
              exact
              path="/cases/import"
              contentComponent={CasesImport}
            />
            <Route exact path="/">
              <Redirect to={isAuthenticated ? '/dashboard' : '/login'} />
            </Route>
            <Route contentComponent={NotFound} />
          </Switch>
        </Router>
      </ErrorBoundary>
    </div>
  )
}

export default App
