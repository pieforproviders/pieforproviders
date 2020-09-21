import { useHistory } from 'react-router-dom'
import { RevokeAuthentication } from '_utils/authenticationHandler'

const useUnauthorizedHandler = () => {
  let history = useHistory()
  let revocation = RevokeAuthentication

  const handler = response => {
    // TODO: Sentry
    revocation()
    history.push('/login')
    return response
  }

  return handler
}

export default useUnauthorizedHandler
