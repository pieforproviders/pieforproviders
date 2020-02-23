import React from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
} from 'react-router-dom'
import Dashboard from './Dashboard'
import Login from './Login'
import NotFound from './NotFound'
import ReactGA from 'react-ga'

function App() {
  ReactGA.initialize('UA-117297491-1', { testMode: true })
  return (
    <Router>
      <Switch>
        <Route path="/login">
          <Login />
        </Route>
        <Route path="/dashboard">
          <Dashboard />
        </Route>
        <Route exact path="/">
          <Redirect to={'/login'} />
        </Route>
        <Route component={NotFound} />
      </Switch>
    </Router>
  )
}

export default App
