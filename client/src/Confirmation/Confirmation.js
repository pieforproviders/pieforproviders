import { useEffect } from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Confirmation({ location }) {
  const { makeRequest } = useApiResponse()
  let history = useHistory()

  useEffect(() => {
    let isSubscribed = true
    const confirm = async () => {
      const token = location.search.split('=')[1]
      const response = await makeRequest({
        type: 'get',
        url: `${location.pathname}${
          token ? `?confirmation_token=${token}` : ''
        }`
      })
      if (isSubscribed) {
        if (!response.ok || response.headers.get('authorization') === null) {
          const errorMessage = await response.json()
          localStorage.removeItem('pie-token')
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
          localStorage.setItem(
            'pie-token',
            response.headers.get('authorization')
          )
          history.push('/getting-started')
        }
      }
    }
    confirm()
    return () => (isSubscribed = false)
  }, [history, location.pathname, location.search, makeRequest])

  return null
}

Confirmation.propTypes = {
  location: PropTypes.object.isRequired
}
