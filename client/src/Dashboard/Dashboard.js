import React, { useEffect, useState } from 'react'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Dashboard() {
  const [businessList, setBusinessList] = useState([])
  const { makeRequest } = useApiResponse()
  useEffect(() => {
    const responseValue = async () => {
      const businesses = await makeRequest({
        type: 'get',
        url: '/api/v1/businesses',
        headers: {
          Accept: 'application/vnd.pieforproviders.v1+json',
          'Content-Type': 'application/json',
          Authorization: localStorage.getItem('pie-token')
        }
      })
      const allBusinesses = await businesses.json()
      if (!allBusinesses.error) {
        setBusinessList(allBusinesses)
      }
    }

    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    responseValue()
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="dashboard">
      <h1>This is the dashboard</h1>
      {businessList &&
        businessList.map(business => {
          return <div key={business.name}>{business.name}</div>
        })}
    </div>
  )
}
