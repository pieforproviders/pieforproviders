import React, { useState, useEffect } from 'react'
import { NavLink } from 'react-router-dom'
import './Login.css'
import ReactGA from 'react-ga'
import { sha1 } from 'hash-anything'
import { useApi } from 'react-use-fetch-api'

export function Login() {
  ReactGA.pageview(window.location.pathname + window.location.search)
  ReactGA.event({
    category: 'Guest',
    action: 'Landed on Login Page'
  })

  const { get } = useApi()

  const [users, setUsers] = useState([])

  useEffect(() => {
    get('/api/v1/users', {
      Accept: 'application/vnd.pieforproviders.v1+json'
    }).then(data => {
      setUsers(data)
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="login">
      <h1>
        Users would normally login here and then be redirected to their
        Dashboard
      </h1>
      {users.map(user => (
        <p key={sha1(user.email, user.full_name)}>
          {user.full_name}: {user.email}{' '}
          <NavLink to={`/setup`}>Click Me</NavLink>
        </p>
      ))}
      <p>Testing new content deploy</p>
    </div>
  )
}
