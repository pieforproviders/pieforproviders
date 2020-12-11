import { createSlice } from '@reduxjs/toolkit'

const initialState = {}

const user = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser(state, action) {
      const user = action.payload

      return {
        ...state,
        ...user
      }
    },
    deleteUser() {
      return initialState
    }
  }
})

export const { setUser, deleteUser } = user.actions
export default user.reducer
