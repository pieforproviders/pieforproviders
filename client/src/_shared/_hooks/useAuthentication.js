import createPersistedState from 'use-persisted-state'
const useTokenState = createPersistedState('pie-token')
const useExpirationState = createPersistedState('pie-expiration')

const useAuthentication = () => {
  const [token, setToken] = useTokenState(null)
  const [expiration, setExpiration] = useExpirationState(Date.now())

  return {
    token,
    setToken,
    expiration,
    setExpiration
  }
}

export default useAuthentication
