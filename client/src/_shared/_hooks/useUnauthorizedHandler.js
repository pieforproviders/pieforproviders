import { useHistory } from 'react-router-dom'
import { useAuthentication } from '_shared/_hooks/useAuthentication'

export default function useUnauthorizedHandler() {
  let history = useHistory()
  const { removeToken } = useAuthentication()

  const handler = response => {
    // TODO: Sentry
    removeToken()
    history.push('/login')
    return response
  }

  return handler
}
