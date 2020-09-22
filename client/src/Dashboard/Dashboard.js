import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useAuthToken } from '_shared/_hooks/useAuthToken'

export function Dashboard() {
  const [businessList, setBusinessList] = useState([])
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()
  const [authToken] = useAuthToken()

  useEffect(() => {
    const responseValue = async () => {
      const businesses = await makeRequest({
        type: 'get',
        url: '/api/v1/businesses',
        headers: {
          Accept: 'application/vnd.pieforproviders.v1+json',
          'Content-Type': 'application/json',
          Authorization: authToken
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
      <h1>{t('dashboardTitle')}</h1>
      {businessList &&
        businessList.map(business => {
          return <div key={business.name}>{business.name}</div>
        })}
    </div>
  )
}
