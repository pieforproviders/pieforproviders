import { createSlice } from '@reduxjs/toolkit'

const initialState = []

const cases = createSlice({
  name: 'cases',
  initialState,
  reducers: {
    setCaseData(_state, action) {
      const cases = action.payload
      return [...cases]
    },
    updateCase(state, action) {
      const { childId, updates } = action.payload
      const childIndex = state.findIndex(c => c.id === childId)

      return [
        ...state.slice(0, childIndex),
        { ...state[childIndex], ...updates },
        ...state.slice(childIndex + 1)
      ]
    }
  }
})

export const { setCaseData, updateCase } = cases.actions
export default cases.reducer
