export const removeEmptyStringValue = obj =>
  Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== ''))

export default removeEmptyStringValue
