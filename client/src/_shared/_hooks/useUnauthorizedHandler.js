import { useHistory } from 'react-router-dom'
import { revokeAuthentication } from '_utils/authenticationHandler'

const useUnauthorizedHandler = () => {
  let history = useHistory()

  const handler = response => {
    // TODO: Sentry
    revokeAuthentication()
    history.push('/login')
    return response
  }

  return handler
}

export default useUnauthorizedHandler
