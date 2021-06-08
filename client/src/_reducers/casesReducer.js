import { createSlice } from '@reduxjs/toolkit'

const initialState = []

const cases = createSlice({
  name: 'cases',
  initialState,
  reducers: {
    setCaseData(state, action) {
      const cases = action.payload
      return [...state, ...cases]
    }
  }
})

export const { setCaseData } = cases.actions
export default cases.reducer
