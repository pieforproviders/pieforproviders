import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Route,
  Routes,
  useLocation
} from 'react-router-dom'
import useHotjar from 'react-use-hotjar'
import { useSelector } from 'react-redux'
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

const env = runtimeEnv()

const AppRoutes = () => {
  const { t } = useTranslation()
  const { initHotjar } = useHotjar()
  const isAuthenticated = useAuthentication()
  const user = useSelector(state => state.user)
  let location = useLocation()

  useEffect(() => {
    if (env.REACT_APP_HOTJAR_ID) {
      initHotjar(env.REACT_APP_HOTJAR_ID, env.REACT_APP_HOTJAR_SV)
    }
    if (!window.gtag) return
    window.gtag('config', env.REACT_APP_GA_MEASUREMENT_ID, {
      page_path: location.pathname,
      user_id: user.id ?? ''
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
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
      <Routes>
        <Route
          path="/signup"
          element={
            <AuthLayout
              backgroundImageClass="auth-image"
              contentComponent={Signup}
            />
          }
        />
        <Route
          path="/login"
          element={
            <AuthLayout
              backgroundImageClass="auth-image"
              contentComponent={Login}
            />
          }
        />
        <Route
          path="/password/update"
          element={
            <AuthLayout
              backgroundImageClass="auth-image"
              contentComponent={NewPassword}
            />
          }
        />
        <Route
          path="/confirm"
          title="Confirm your Account"
          element={<Confirmation />}
        />
        <Route
          path="/getting-started"
          title={t('setup')}
          element={
            <AuthenticatedRoute>
              <GettingStarted />
            </AuthenticatedRoute>
          }
        />
        <Route
          path="/dashboard"
          element={
            <AuthenticatedRoute>
              <Dashboard />
            </AuthenticatedRoute>
          }
        />
        <Route
          path="/attendance"
          element={
            <AuthenticatedRoute>
              <AttendanceView />
            </AuthenticatedRoute>
          }
        />
        <Route
          path="/attendance/edit"
          element={
            <AuthenticatedRoute>
              <Attendance />
            </AuthenticatedRoute>
          }
        />
        <Route
          path="/cases/import"
          element={
            <AuthenticatedRoute>
              <CasesImport />
            </AuthenticatedRoute>
          }
        />
        <Route
          exact
          path="/"
          element={
            isAuthenticated ? (
              <AuthenticatedRoute>
                <Dashboard />
              </AuthenticatedRoute>
            ) : (
              <AuthLayout
                backgroundImageClass="auth-image"
                contentComponent={Login}
              />
            )
          }
        />
        <Route element={NotFound} />
      </Routes>
    </div>
  )
}

const App = () => {
  return (
    <Router>
      <ErrorBoundary>
        <AppRoutes />
      </ErrorBoundary>
    </Router>
  )
}

export default App
