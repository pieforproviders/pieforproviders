import { useEffect } from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import useApiResponse from '_shared/_hooks/useApiResponse'
import {
  RevokeAuthentication,
  SetAuthentication
} from '_utils/authenticationHandler'

export function Confirmation({ location }) {
  const { makeRequest } = useApiResponse()
  let history = useHistory()
  const revocation = RevokeAuthentication
  const setAuth = SetAuthentication

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
      const authorizationHeader = response.headers.get('authorization')
      if (isSubscribed) {
        if (!response.ok || authorizationHeader === null) {
          const errorMessage = await response.json()
          revocation()
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
          setAuth(
            authorizationHeader /*, expiration: parse the JWT for its expiration time */
          )
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
    revocation,
    setAuth
  ])

  return null
}

Confirmation.propTypes = {
  location: PropTypes.object.isRequired
}
