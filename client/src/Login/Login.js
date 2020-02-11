import React from 'react'
import { Link } from 'react-router-dom'
import './Login.css'

export function Login() {
  return (
    <div className='Login'>
      <p>
        Don't look here, look at the <Link to='/dashboard'>Dashboard</Link>
      </p>
    </div>
  )
}
