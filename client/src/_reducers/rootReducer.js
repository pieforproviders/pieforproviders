import { combineReducers } from 'redux'
import auth from '_reducers/authReducer'
import cases from '_reducers/casesReducer'
import user from '_reducers/userReducer'

const rootReducer = combineReducers({
  auth,
  cases,
  user
})

export default rootReducer
