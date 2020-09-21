import { useContext } from 'react'
import { AuthContext } from '_contexts/AuthContext'

export function IsAuthenticated() {
  // TODO: expiration
  // const { userToken, tokenExpiration } = useContext(AuthContext)
  const { userToken } = useContext(AuthContext)

  return !!userToken
}

export function RevokeAuthentication() {
  const { setUserToken, setTokenExpiration } = useContext(AuthContext)

  setUserToken(null)
  setTokenExpiration(Date.now())
  return null
}

export function SetAuthentication(token, expiration = null) {
  const { setUserToken, setTokenExpiration } = useContext(AuthContext)

  setUserToken(token)
  setTokenExpiration(expiration)
  return null
}
