import dayjs from 'dayjs'
import { createLocalStorageStateHook } from 'use-local-storage-state'

const useAuthentication = () => {
  const useToken = createLocalStorageStateHook('pie-token', null)
  const useExpiration = createLocalStorageStateHook(
    'pie-expiration',
    Date.now()
  )

  const [token, setToken] = useToken()
  const [expiration, setExpiration] = useExpiration()

  const revokeAuthentication = () => {
    setToken(null)
    setExpiration(dayjs())
  }

  const setAuthentication = (token, expiration = dayjs().add('1', 'day')) => {
    setToken(token)
    setExpiration(expiration)
  }

  return {
    userToken: token,
    setUserToken: setToken,
    tokenExpiration: expiration,
    isAuthenticated: token !== null,
    setTokenExpiration: setExpiration,
    setAuthentication: setAuthentication,
    revokeAuthentication: revokeAuthentication
  }
}

export default useAuthentication
