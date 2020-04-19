import React from 'react'
import './Setup.css'
import { sha1 } from 'hash-anything'
import { useQuery } from 'react-query'
import { getBusinesses } from '../api'

export function Setup() {
  const { status, data: businesses, error } = useQuery(
    'businesses',
    getBusinesses
  )

  return (
    <div className="setup">
      <p>Businesses</p>
      <p>
        This content is only to display something here - eventually this will be
        the setup wizard
      </p>
      {status === 'loading' && <div>Loading...</div>}
      {status === 'error' && <div>Error: {error.message}</div>}
      {businesses?.map(business => (
        <div key={sha1(business.slug, business.name)}>
          {business.name} ({business.id})
        </div>
      ))}
    </div>
  )
}
