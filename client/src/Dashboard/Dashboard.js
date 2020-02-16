import React, { useEffect, useState } from 'react'
import './Dashboard.css'

export function Dashboard() {
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
      <h1>This is the dashboard</h1>
      <p>Here are all the users:</p>
      {users.map(user => (
        <p key={user.email}>
          {user.full_name}: {user.email}
        </p>
      ))}
    </div>
  )
}
