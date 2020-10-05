export const ADD_AUTH = 'ADD_AUTH'
export const REMOVE_AUTH = 'REMOVE_AUTH'

export function addAuth(token) {
  return {
    type: ADD_AUTH,
    token
  }
}

export function removeAuth() {
  return {
    type: REMOVE_AUTH
  }
}
