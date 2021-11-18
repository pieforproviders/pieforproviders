import { useEffect } from 'react'
import PropTypes from 'prop-types'
import { useLocation, useNavigate } from 'react-router-dom'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useDispatch } from 'react-redux'
import { addAuth, removeAuth } from '_reducers/authReducer'

export function Confirmation() {
  const dispatch = useDispatch()
  const { makeRequest } = useApiResponse()
  let navigate = useNavigate()
  let location = useLocation()

  useEffect(() => {
    let isSubscribed = true
    const confirm = async () => {
      const params = new URLSearchParams(location.search)
      const confirmationToken = params.get('confirmation_token')

      const response = await makeRequest({
        type: 'get',
        url: `confirmation${
          confirmationToken ? `?confirmation_token=${confirmationToken}` : ''
        }`
      })
      const authToken = response.headers.get('authorization')
      if (isSubscribed) {
        if (!response.ok || authToken === null) {
          const errorMessage = await response.json()
          dispatch(removeAuth())
          navigate({
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
          dispatch(addAuth(authToken))
          navigate('/dashboard')
        }
      }
    }
    confirm()
    return () => (isSubscribed = false)
    // we only want this to run once; making the makeRequest hook a dependency causes an infinite re-run of this query
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return null
}

Confirmation.propTypes = {
  location: PropTypes.object.isRequired
}
