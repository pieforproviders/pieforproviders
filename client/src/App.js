import React from 'react'
import {
  BrowserRouter as Router,
  Redirect,
  Route,
  Switch
} from 'react-router-dom'
import ReactGA from 'react-ga'
import Dashboard from './Dashboard'
import Import from './Import'
import Login from './Login'
import NotFound from './NotFound'
import Setup from './Setup'

function App() {
  ReactGA.initialize('UA-117297491-1', { testMode: true })
  console.log('app.js loaded')
  return (
    <Router>
      <Switch>
        <Route path="/login">
          <Login />
        </Route>
        <Route path="/dashboard">
          <Dashboard />
        </Route>
        <Route path="/:id/setup">
          <Setup />
        </Route>
        <Route path="/:id/import">
          <Import />
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
