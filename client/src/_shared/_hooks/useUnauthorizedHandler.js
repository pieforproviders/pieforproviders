import { useContext } from 'react'
import { AuthContext } from '_contexts/AuthContext'
import { useHistory } from 'react-router-dom'

const useUnauthorizedHandler = () => {
  let history = useHistory()
  const { setUserToken, setTokenExpiration } = useContext(AuthContext)

  const handler = response => {
    // TODO: Sentry
    setUserToken(null)
    setTokenExpiration(Date.now())
    history.push('/login')
    return response
  }

  return handler
}

export default useUnauthorizedHandler
