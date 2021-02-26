import { useHistory } from 'react-router-dom'
import { useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'
import { sendSpan } from '../_utils/appSignal'

export default function useUnauthorizedHandler() {
  const dispatch = useDispatch()
  let history = useHistory()

  const handler = response => {
    sendSpan({
      params: response,
      error: new Error('API Unauthorized 400 error')
    })

    dispatch(removeAuth())
    history.push('/login')
    return response
  }

  return handler
}
