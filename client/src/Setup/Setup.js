import React, { useEffect, useState } from 'react'
import { NavLink, useParams } from 'react-router-dom'
import './Setup.css'

export function Setup() {
  const params = useParams()
  const [businesses, setBusinesses] = useState([])

  useEffect(() => {
    fetch(`/api/v1/users/${params.id}/businesses`, {
      headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
    })
      .then(response => response.json())
      .then(json => setBusinesses(json))
      .catch(error => console.log(error))
  }, [])
  return (
    <>
      {businesses?.map(business => (
        <div key={business.id}>
          <NavLink to={`/${business.id}/import`}>{business.name}</NavLink>
        </div>
      ))}
    </>
  )
}
