import React from 'react'
import { NavLink } from 'react-router-dom'
import './Login.css'
import ReactGA from 'react-ga'
import { sha1 } from 'hash-anything'
import { useQuery } from 'react-query'
import { getUsers } from '../api'

export function Login() {
  ReactGA.pageview(window.location.pathname + window.location.search)
  ReactGA.event({
    category: 'Guest',
    action: 'Landed on Login Page'
  })

  const { status, data: users, error } = useQuery('users', getUsers)

  return (
    <div className="login">
      <h1>
        Users would normally login here and then be redirected to their
        Dashboard
      </h1>
      {status === 'loading' && <div>Loading...</div>}
      {status === 'error' && <div>Error: {error.message}</div>}
      {users?.map(user => (
        <p key={sha1(user.email, user.full_name)}>
          {user.full_name}: {user.email}{' '}
          <NavLink to={`/setup`}>Click Me</NavLink>
        </p>
      ))}
      <p>Testing new content deploy</p>
    </div>
  )
}
