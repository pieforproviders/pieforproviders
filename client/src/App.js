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
import Login from './Login'
import Signup from './Signup'
import Confirmation from './Signup/Confirmation'
import NotFound from './NotFound'
import ErrorBoundary from './ErrorBoundary'
import CasesImport from './CasesImport'
import { AuthLayout } from '_shared'
import { isUserLoggedIn } from '_utils'

const App = () => {
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
            <AuthorizedRoute exact path="/getting-started" title="Setup">
              <GettingStarted />
            </AuthorizedRoute>
            <AuthorizedRoute exact path="/dashboard">
              <Dashboard />
            </AuthorizedRoute>
            <AuthorizedRoute exact path="/cases/import">
              <CasesImport />
            </AuthorizedRoute>
            <Route path="/confirmation">
              <AuthLayout
                backgroundImageClass="auth-image"
                contentComponent={Confirmation}
              />
            </Route>
            <Route exact path="/">
              <Redirect to={isUserLoggedIn ? '/dashboard' : '/login'} />
            </Route>
            <Route component={NotFound} />
          </Switch>
        </Router>
      </ErrorBoundary>
    </div>
  )
}

export default App
