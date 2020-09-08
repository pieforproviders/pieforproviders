export const createSelector = id => `[data-cy="${id}"]`

export const camelToSnakeCase = str =>
  str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`)
