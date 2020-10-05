import dayjs from 'dayjs'
import jwt_decode from 'jwt-decode'
import { ADD_AUTH, REMOVE_AUTH } from '_actions/auth'

const initialAuthState = {
  token: localStorage.getItem('pie-token'),
  expiration: dayjs(localStorage.getItem('pie-expiration')) || dayjs()
}

export default function auth(state = initialAuthState, action) {
  const expiration = action.token
    ? dayjs.unix(jwt_decode(action.token).exp).toDate()
    : null

  switch (action.type) {
    case ADD_AUTH:
      /*
        we're using local storage here so we can re-sign the user in as long as
        their token hasn't expired
      */
      localStorage.setItem('pie-token', action.token)
      localStorage.setItem('pie-expiration', expiration)

      return {
        ...state,
        token: action.token,
        expiration
      }
    case REMOVE_AUTH:
      /*
        we're clearing local storage here on any logout event or anything that seems
        like it should invalidate someone's "session"
      */
      localStorage.removeItem('pie-token')
      localStorage.removeItem('pie-expiration')

      return {
        ...state,
        token: null,
        expiration
      }
    default:
      return state
  }
}
