import { createSlice } from '@reduxjs/toolkit'

const initialState = {}

const ui = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    setFilteredCases(state, action) {
      const filteredCases = action.payload
      return { ...state, filteredCases: [...filteredCases] }
    },
    setLoading(state, action) {
      const isLoading = action.payload
      return {
        ...state,
        isLoading
      }
    },
    setProgress(state, action) {
      const progress = action.payload

      return {
        ...state,
        progress
      }
    }
  }
})

export const { setFilteredCases, setLoading, setProgress } = ui.actions
export default ui.reducer
