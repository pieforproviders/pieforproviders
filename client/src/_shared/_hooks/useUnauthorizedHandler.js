import { useNavigate } from 'react-router-dom'
import { useDispatch } from 'react-redux'
import { removeAuth } from '_reducers/authReducer'
import { sendSpan } from '../../_utils/appSignal'

export default function useUnauthorizedHandler() {
  const dispatch = useDispatch()
  let navigate = useNavigate()

  const handler = response => {
    sendSpan({
      params: response,
      error: new Error('API Unauthorized 400 error')
    })

    dispatch(removeAuth())
    navigate('/login')
    return response
  }

  return handler
}
