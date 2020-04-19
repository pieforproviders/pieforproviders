import React, { useEffect, useState } from 'react'
import './Setup.css'
import { sha1 } from 'hash-anything'
import { useApi } from 'react-use-fetch-api'

export function Setup() {
  let { get } = useApi()
  const [businesses, setBusinesses] = useState([])

  useEffect(() => {
    get('/api/v1/businesses', {
      Accept: 'application/vnd.pieforproviders.v1+json'
    }).then(data => {
      setBusinesses(data)
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
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
