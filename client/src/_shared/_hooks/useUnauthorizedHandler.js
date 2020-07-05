import { useHistory } from 'react-router-dom'

export default function useUnauthorizedHandler() {
  let history = useHistory()

  const handler = response => {
    // TODO: Sentry
    localStorage.removeItem('token')
    history.push('/login')
    return response
  }

  return handler
}
