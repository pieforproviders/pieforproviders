import { useHistory } from 'react-router-dom'

export default function useUnauthorizedHandler() {
  let history = useHistory()

  const handler = err => {
    console.log('unauthorized err:', err)
    // TODO: Sentry
    localStorage.removeItem('token')
    history.push('/login')
    return 3
  }

  return handler
}
