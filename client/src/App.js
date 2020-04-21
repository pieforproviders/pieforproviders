import React from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
} from 'react-router-dom'
import ReactGA from 'react-ga'
import Dashboard from './Dashboard'
import Login from './Login'
import NotFound from './NotFound'
import ErrorBoundary from './ErrorBoundary'
import Setup from './Setup'

function App() {
  ReactGA.initialize('UA-117297491-1', { testMode: true })

  return (
    <ErrorBoundary>
      <Router>
        <Switch>
          <Route path="/login">
            <Login />
          </Route>
          <Route path="/dashboard">
            <Dashboard />
          </Route>
          <Route path="/setup">
            <Setup />
          </Route>
          <Route exact path="/">
            <Redirect to={'/login'} />
          </Route>
          <Route component={NotFound} />
        </Switch>
      </Router>
    </ErrorBoundary>
  )
}

export default App
