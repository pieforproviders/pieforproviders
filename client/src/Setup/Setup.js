import React, { useEffect, useState } from 'react'
import { NavLink, useParams } from 'react-router-dom'
import './Setup.css'

export function Setup() {
  const { id } = useParams()
  const [businesses, setBusinesses] = useState([])

  useEffect(() => {
    const userBusinesses = async () => {
      const result = await fetch(`/api/v1/users/${id}/businesses`, {
        headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
      })

      setBusinesses(await result.json())
    }

    userBusinesses()
  }, [id])

  return (
    <div className="setup">
      <p>Businesses for user {id}</p>
      {businesses?.map(business => (
        <div key={business.id}>
          <NavLink to={`/${business.id}/import`}>{business.name}</NavLink>
        </div>
      ))}
    </div>
  )
}
