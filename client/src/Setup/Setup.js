import React, { useEffect, useState } from 'react'
import './Setup.css'
import { sha1 } from 'hash-anything'

export function Setup() {
  const [businesses, setBusinesses] = useState([])

  useEffect(() => {
    // TODO: useApi from react-use-fetch-api after making a PR for headers
    const businesses = async () => {
      const result = await fetch('/api/v1/businesses', {
        headers: { Accept: 'application/vnd.pieforproviders.v1+json' }
      })

      setBusinesses(await result.json())
    }

    businesses()
  }, [])

  return (
    <div className="setup">
      <p>Businesses</p>
      <p>
        This content is only to display something here - eventually this will be
        the setup wizard
      </p>
      {businesses?.map(business => (
        <div key={sha1(business.slug, business.name)}>
          {business.name} ({business.id})
        </div>
      ))}
    </div>
  )
}
