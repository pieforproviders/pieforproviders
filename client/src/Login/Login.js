import React from 'react'
import { Link } from 'react-router-dom'
import './Login.css'

export function Login() {
  return (
    <div className="login">
      Visit the <Link to="dashboard">Dashboard</Link>
    </div>
  )
}
