import { useContext, useEffect } from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import useApiResponse from '_shared/_hooks/useApiResponse'
import { AuthContext } from '_contexts/AuthContext'

export function Confirmation({ location }) {
  const { makeRequest } = useApiResponse()
  const { setAuthenticated, setUserToken, setTokenExpiration } = useContext(
    AuthContext
  )
  let history = useHistory()

  useEffect(() => {
    let isSubscribed = true
    const confirm = async () => {
      const confirmationToken = location.search.split('=')[1]
      const response = await makeRequest({
        type: 'get',
        url: `confirmation${
          confirmationToken ? `?confirmation_token=${confirmationToken}` : ''
        }`
      })
      if (isSubscribed) {
        if (!response.ok || response.headers.get('authorization') === null) {
          const errorMessage = await response.json()
          setTokenExpiration(Date.now)
          setUserToken(null)
          setAuthenticated(false)
          history.push({
            pathname: '/login',
            state: {
              error: {
                status: response.status,
                message: errorMessage.error,
                attribute: errorMessage.attribute,
                type: errorMessage.type
              }
            }
          })
        } else {
          setUserToken(response.headers.get('authorization'))
          // setTokenExpiration(/* implementation: parse the JWT for its expiration time */)
          setAuthenticated(true)
          history.push('/getting-started')
        }
      }
    }
    confirm()
    return () => (isSubscribed = false)
  }, [
    history,
    location.pathname,
    location.search,
    makeRequest,
    setAuthenticated,
    setUserToken,
    setTokenExpiration
  ])

  return null
}

Confirmation.propTypes = {
  location: PropTypes.object.isRequired
}
