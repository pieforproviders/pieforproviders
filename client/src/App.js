import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
} from 'react-router-dom'
import AuthorizedRoute from '_utils/_routes/AuthorizedRoute.js'
import ReactGA from 'react-ga'
import Dashboard from './Dashboard'
import GettingStarted from './GettingStarted'
import Confirmation from './Confirmation'
import Login from './Login'
import Signup from './Signup'
import NotFound from './NotFound'
import ErrorBoundary from './ErrorBoundary'
import CasesImport from './CasesImport'
import { Layout } from 'antd'
import { AuthLayout } from '_shared'
import { isUserLoggedIn } from '_utils'
import { useTranslation } from 'react-i18next'

const App = () => {
  const { t } = useTranslation()

  useEffect(() => {
    /* skip production code for coverage */
    /* istanbul ignore next */
    if (process.env.NODE_ENV === 'production') {
      ReactGA.initialize('UA-117297491-1')
    }
  }, [])

  return (
    <Layout
      breakpoint={{
        xs: '0px',
        sm: '360px',
        md: '768px',
        lg: '1024px',
        xl: '1280px'
      }}
      className="bg-white"
    >
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
              <Route
                path="/confirm"
                title="Confirm your Account"
                component={Confirmation}
              />
              <AuthorizedRoute exact path="/getting-started" title={t('setup')}>
                <GettingStarted />
              </AuthorizedRoute>
              <AuthorizedRoute exact path="/dashboard">
                <Dashboard />
              </AuthorizedRoute>
              <AuthorizedRoute exact path="/cases/import">
                <CasesImport />
              </AuthorizedRoute>
              <Route exact path="/">
                <Redirect to={isUserLoggedIn ? '/dashboard' : '/login'} />
              </Route>
              <Route component={NotFound} />
            </Switch>
          </Router>
        </ErrorBoundary>
      </div>
    </Layout>
  )
}

export default App
