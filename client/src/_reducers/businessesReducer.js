import { createSlice } from '@reduxjs/toolkit'

const initialState = []

const businesses = createSlice({
  name: 'businesses',
  initialState,
  reducers: {
    setBusinesses(_state, action) {
      const businesses = action.payload
      return [...businesses]
    },
    deleteBusinesses() {
      return initialState
    }
  }
})

export const { setBusinesses, deleteBusinesses } = businesses.actions
export default businesses.reducer
