import dayjs from 'dayjs'

export function useAuthentication() {
  const setToken = (token, expiration = dayjs().add('1', 'day')) => {
    localStorage.setItem('pie-token', token)
    localStorage.setItem('pie-expiration', expiration)
  }

  const isAuthenticated =
    !!localStorage.getItem('pie-token') &&
    localStorage.getItem('pie-expiration') > dayjs()

  const removeToken = () => {
    localStorage.removeItem('pie-token')
    localStorage.removeItem('pie-expiration')
  }

  return {
    isAuthenticated: isAuthenticated,
    storedToken: localStorage.getItem('pie-token'),
    setToken: setToken,
    removeToken: removeToken
  }
}
