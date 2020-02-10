import React, { useEffect, useState } from 'react'
import logo from './logo.svg'
import './App.css'

function App() {
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
    <div className='App'>
      <header className='App-header'>
        <img src={logo} className='App-logo' alt='logo' />
        <p>
          {users.map(user => (
            <p key={user.email}>
              {user.full_name}: {user.email}
            </p>
          ))}
        </p>
        <a
          className='App-link'
          href='https://reactjs.org'
          target='_blank'
          rel='noopener noreferrer'
        >
          Learn React
        </a>
      </header>
    </div>
  )
}

export default App
