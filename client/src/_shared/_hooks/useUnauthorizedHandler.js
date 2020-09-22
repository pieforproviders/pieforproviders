import { useHistory } from 'react-router-dom'
import useAuthentication from '_shared/_hooks/useAuthentication'

const useUnauthorizedHandler = () => {
  let history = useHistory()
  const { revokeAuthentication } = useAuthentication()

  const handler = response => {
    // TODO: Sentry
    revokeAuthentication()
    history.push('/login')
    return response
  }

  return handler
}

export default useUnauthorizedHandler
