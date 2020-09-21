import useLocalStorageState from 'use-local-storage-state'

const useAuthentication = () => {
  const [token, setToken] = useLocalStorageState('pie-token', null)
  const [expiration, setExpiration] = useLocalStorageState(
    'pie-expiration',
    Date.now()
  )

  return {
    token: token,
    setToken: setToken,
    expiration: expiration,
    setExpiration: setExpiration
  }
}

export default useAuthentication
