import React from 'react'
import { Link } from 'react-router-dom'
import './Login.css'
import ReactGA from 'react-ga'

export function Login() {
  ReactGA.initialize('UA-117297491-1')
  ReactGA.pageview(window.location.pathname + window.location.search)
  ReactGA.event({
    category: 'Guest',
    action: 'Landed on Login Page'
  })
  return (
    <div className="login">
      A user would normally log in here. But for now, visit the{' '}
      <Link to="dashboard">Dashboard</Link>
    </div>
  )
}
