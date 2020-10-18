import { useHistory } from 'react-router-dom'
import { useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'

export default function useUnauthorizedHandler() {
  const dispatch = useDispatch()
  let history = useHistory()

  const handler = response => {
    // TODO: Sentry
    dispatch(removeAuth())
    history.push('/login')
    return response
  }

  return handler
}
