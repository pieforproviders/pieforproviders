import dayjs from 'dayjs'
import jwt_decode from 'jwt-decode'
import { createSlice } from '@reduxjs/toolkit'

/*
  The use of .format on dayjs returns the ISO8601 string.
  This is an arbitrary format decision; Redux Toolkit won't store
  non-serializable data, so we need to turn it into SOME string
*/

const initialAuthState = () => {
  const token = localStorage.getItem('pie-token')
  const expiration = localStorage.getItem('pie-expiration')
  return {
    token,
    expiration: expiration || dayjs().format()
  }
}

const auth = createSlice({
  name: 'auth',
  initialState: initialAuthState(),
  reducers: {
    addAuth(state, action) {
      const token = action.payload
      /*
        JWT Decoder returns UNIX timestamp in seconds, so we need to use .unix to parse it
      */
      const expiration = dayjs.unix(jwt_decode(token).exp).format()
      localStorage.setItem('pie-token', token)
      localStorage.setItem('pie-expiration', expiration)
      return {
        ...state,
        token,
        expiration
      }
    },
    removeAuth(state) {
      localStorage.removeItem('pie-token')
      localStorage.removeItem('pie-expiration')
      return {
        ...state,
        token: null,
        expiration: dayjs().format()
      }
    }
  }
})

export const { addAuth, removeAuth } = auth.actions
export default auth.reducer
