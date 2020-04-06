import React, { useState, useEffect } from 'react'
import { NavLink } from 'react-router-dom'
import './Login.css'
import ReactGA from 'react-ga'

export function Login() {
  ReactGA.pageview(window.location.pathname + window.location.search)
  ReactGA.event({
    category: 'Guest',
    action: 'Landed on Login Page'
  })

  const [users, setUsers] = useState([])

  useEffect(() => {
    fetch('/api/v1/users', {
      headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
    })
      .then(response => response.json())
      .then(json => setUsers(json))
      .catch(error => console.log(error))
  }, [])
  return (
    <div className="dashboard">
      <h1>
        Users would normally login here and then be redirected to their
        Dashboard
      </h1>
      {users.map(user => (
        <p key={user.email}>
          {user.full_name}: {user.email}{' '}
          <NavLink to={`/${user.id}/setup`}>Click Me</NavLink>
        </p>
      ))}
      <p>Testing new content deploy</p>
    </div>
  )
}
