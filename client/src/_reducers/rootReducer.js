import { combineReducers } from 'redux'
import auth from '_reducers/authReducer'
import user from '_reducers/userReducer'

const rootReducer = combineReducers({
  auth,
  user
})

export default rootReducer
