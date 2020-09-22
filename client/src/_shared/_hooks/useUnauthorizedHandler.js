import { useHistory } from 'react-router-dom'
import { useAuthToken } from '_shared/_hooks/useAuthToken'

export default function useUnauthorizedHandler() {
  let history = useHistory()
  const [, setAuthToken] = useAuthToken()

  const handler = response => {
    // TODO: Sentry
    setAuthToken(null)
    history.push('/login')
    return response
  }

  return handler
}
