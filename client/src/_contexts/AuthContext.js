import React, { createContext } from 'react'
import useAuthentication from '_shared/_hooks/useAuthentication'
import { PropTypes } from 'prop-types'

export const AuthContext = createContext({
  userToken: null,
  setUserToken: () => {},
  tokenExpiration: null,
  setTokenExpiration: () => {}
})

export function AuthProvider({ children }) {
  const { token, expiration, setToken, setExpiration } = useAuthentication()

  return (
    <AuthContext.Provider
      value={{
        userToken: token,
        tokenExpiration: expiration,
        setUserToken: setToken,
        setTokenExpiration: setExpiration
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

AuthProvider.propTypes = {
  children: PropTypes.element.isRequired
}
