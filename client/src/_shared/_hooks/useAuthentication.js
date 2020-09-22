import dayjs from 'dayjs'
import useLocalStorageState from 'use-local-storage-state'

const useAuthentication = () => {
  const [token, setToken] = useLocalStorageState('pie-token', null)
  const [expiration, setExpiration] = useLocalStorageState(
    'pie-expiration',
    Date.now()
  )

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
    setTokenExpiration: setExpiration,
    setAuthentication: setAuthentication,
    revokeAuthentication: revokeAuthentication
  }
}

export default useAuthentication
