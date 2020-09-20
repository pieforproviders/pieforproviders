import { useContext } from 'react'
import { AuthContext } from '_contexts/AuthContext'
import { useHistory } from 'react-router-dom'

const useUnauthorizedHandler = () => {
  let history = useHistory()
  const { setAuthenticated, setUserToken, setTokenExpiration } = useContext(
    AuthContext
  )

  const handler = response => {
    // TODO: Sentry
    setAuthenticated(false)
    setUserToken(null)
    setTokenExpiration(Date.now())
    history.push('/login')
    return response
  }

  return handler
}

export default useUnauthorizedHandler
