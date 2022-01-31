import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch,
  useLocation
} from 'react-router-dom'
import useHotjar from 'react-use-hotjar'
import runtimeEnv from '@mars/heroku-js-runtime-env'
import AuthenticatedRoute from '_utils/_routes/AuthenticatedRoute.js'
import Attendance from './Attendance'
import AttendanceView from './AttendanceView'
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
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'

const env = runtimeEnv()

const Routes = () => {
  const { t } = useTranslation()
  const { initHotjar } = useHotjar()
  const isAuthenticated = useAuthentication()
  const { initGoogleAnalytics } = useGoogleAnalytics()
  let location = useLocation()

  useEffect(() => {
    if (env.REACT_APP_HOTJAR_ID) {
      initHotjar(env.REACT_APP_HOTJAR_ID, env.REACT_APP_HOTJAR_SV)
    }

    initGoogleAnalytics()
  }, [initGoogleAnalytics, initHotjar])

  useEffect(() => {
    const script = document.createElement('script')
    script.async = true
    script.src =
      '/mini-profiler-resources/includes.js?v=12b4b45a3c42e6e15503d7a03810ff33'
    script.type = 'text/javascript'
    script.id = 'mini-profiler'
    script.setAttribute(
      'data-css-url',
      '/mini-profiler-resources/includes.css?v=12b4b45a3c42e6e15503d7a03810ff33'
    )
    script.setAttribute('data-version', '12b4b45a3c42e6e15503d7a03810ff33')
    script.setAttribute('data-path', '/mini-profiler-resources/')
    script.setAttribute('data-horizontal-position', 'left')
    script.setAttribute('data-vertical-position', 'top')
    script.setAttribute('data-ids', '')
    script.setAttribute('data-trivial', 'false')
    script.setAttribute('data-children', 'false')
    script.setAttribute('data-max-traces', '20')
    script.setAttribute('data-controls', 'false')
    script.setAttribute('data-total-sql-count', 'false')
    script.setAttribute('data-authorized', 'true')
    script.setAttribute('data-toggle-shortcut', 'Alt+P')
    script.setAttribute('data-start-hidden', 'false')
    script.setAttribute('data-collapse-results', 'true')
    script.setAttribute('data-hidden-custom-fields', '')
    script.setAttribute('data-html-container', 'body')
    document.head.appendChild(script)
  })

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
        <AuthenticatedRoute exact path="/attendance">
          <AttendanceView />
        </AuthenticatedRoute>
        <AuthenticatedRoute exact path="/attendance/edit">
          <Attendance />
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
