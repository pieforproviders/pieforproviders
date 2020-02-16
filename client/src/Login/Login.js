import React from 'react'
import { Link } from 'react-router-dom'
import './Login.css'

export function Login() {
  return (
    <div className="login">
      A user would normally log in here. But for now, visit the{' '}
      <Link to="dashboard">Dashboard</Link>
    </div>
  )
}
