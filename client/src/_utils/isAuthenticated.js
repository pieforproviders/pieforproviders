import { useContext } from 'react'
import { AuthContext } from '_contexts/AuthContext'

export const isAuthenticated = () => {
  // TODO: expiration
  // const { userToken, tokenExpiration } = useContext(AuthContext)
  const { userToken } = useContext(AuthContext)

  return !!userToken
}
