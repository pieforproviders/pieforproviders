import { useContext } from 'react'
import { AuthContext } from '_contexts/AuthContext'

export const isAuthenticated = () => {
  // TODO: expiration
  // const { userToken, tokenExpiration } = useContext(AuthContext)
  const { userToken } = useContext(AuthContext)

  return !!userToken
}

export const revokeAuthentication = () => {
  const { setUserToken, setTokenExpiration } = useContext(AuthContext)

  setUserToken(null)
  setTokenExpiration(Date.now())
}

export const setAuthentication = (token, expiration = null) => {
  const { setUserToken, setTokenExpiration } = useContext(AuthContext)

  setUserToken(token)
  setTokenExpiration(expiration)
}
