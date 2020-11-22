import { combineReducers } from 'redux'
import auth from '_reducers/authReducer'

const rootReducer = combineReducers({
  auth
})

export default rootReducer
