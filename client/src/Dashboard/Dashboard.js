import React, { useEffect, useState } from 'react'
import './Dashboard.css'

export function Dashboard() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    const users = async () => {
      const result = await fetch(`/api/v1/users`, {
        headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
      })

      setUsers(await result.json())
    }

    users()
  }, [])

  return (
    <div className="dashboard">
      <h1>This is the dashboard</h1>
      <p>Here are all the users:</p>
      {users?.map(user => (
        <p key={user.email}>
          {user.full_name}: {user.email}
        </p>
      ))}
      <p>Testing new content deploy</p>
    </div>
  )
}
