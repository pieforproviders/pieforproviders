import React, { useEffect } from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
} from 'react-router-dom'
import ReactGA from 'react-ga'
import AuthorizedRoute from './_utils/_routes/AuthorizedRoute'
import Dashboard from './Dashboard'
import Login from './Login'
import Signup from './Signup'
import Confirmation from './Signup/Confirmation'
import NotFound from './NotFound'
import ErrorBoundary from './ErrorBoundary'
import CSVImport from './CSVImport'

const App = () => {
  useEffect(() => {
    /* skip production code for coverage */
    /* istanbul ignore next */
    if (process.env.NODE_ENV === 'production') {
      ReactGA.initialize('UA-117297491-1')
    }
  }, [])

  return (
    <div className="text-primaryBlue font-proxima text-sm">
      <ErrorBoundary>
        <Router>
          <Switch>
            <Route path="/signup">
              <Signup />
            </Route>
            <Route path="/login">
              <Login />
            </Route>
            <AuthorizedRoute path="/dashboard">
              <Dashboard />
            </AuthorizedRoute>
            <AuthorizedRoute path="/csv-import">
              <CSVImport />
            </AuthorizedRoute>
            <Route path="/confirmation">
              <Confirmation />
            </Route>
            <Route exact path="/">
              <Redirect to={'/login'} />
            </Route>
            <Route component={NotFound} />
          </Switch>
        </Router>
      </ErrorBoundary>
    </div>
  )
}

export default App
