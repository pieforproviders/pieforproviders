import React, { useEffect, useState } from 'react'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Dashboard({ token }) {
  const [businessList, setBusinessList] = useState([])
  const { makeRequest } = useApiResponse()
  useEffect(() => {
    const responseValue = async () => {
      const listOfBusinesses = await makeRequest({
        type: 'get',
        url: '/api/v1/businesses',
        headers: {
          Accept: 'application/vnd.pieforproviders.v1+json',
          'Content-Type': 'application/json',
          Authorization: token
        }
      })
      setBusinessList(await listOfBusinesses.json())
    }

    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    responseValue()
  }, [])

  console.log('businessList:', businessList)

  return (
    <div className="dashboard">
      <h1>This is the dashboard</h1>
      {businessList &&
        businessList.map(business => {
          return <div>{business.name}</div>
        })}
    </div>
  )
}
