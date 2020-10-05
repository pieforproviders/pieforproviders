import { useEffect } from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useDispatch } from 'react-redux'
import { addAuth, removeAuth } from '_actions/auth'

export function Confirmation({ location }) {
  const dispatch = useDispatch()
  const { makeRequest } = useApiResponse()
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
          dispatch(removeAuth())
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
          dispatch(addAuth(response.headers.get('authorization')))
          history.push('/getting-started')
        }
      }
    }
    confirm()
    return () => (isSubscribed = false)
  }, [dispatch, history, location.pathname, location.search, makeRequest])

  return null
}

Confirmation.propTypes = {
  location: PropTypes.object.isRequired
}
