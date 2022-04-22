import { combineReducers } from 'redux'
import auth from '_reducers/authReducer'
import businesses from '_reducers/businessesReducer'
import cases from '_reducers/casesReducer'
import ui from '_reducers/uiReducer'
import user from '_reducers/userReducer'

const rootReducer = combineReducers({
  auth,
  businesses,
  cases,
  ui,
  user
})

export default rootReducer
