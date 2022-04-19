/* eslint-disable no-debugger */
import { createSlice } from '@reduxjs/toolkit'

const initialState = {}

const ui = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    setFilteredCases(_state, action) {
      const filteredCases = action.payload
      return [...filteredCases]
    }
  }
})

export const { setFilteredCases } = ui.actions
export default ui.reducer
