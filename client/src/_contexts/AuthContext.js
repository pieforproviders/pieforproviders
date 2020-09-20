import React, { useState, useEffect, createContext } from 'react'
import useAuthentication from '_shared/_hooks/useAuthentication'
import { PropTypes } from 'prop-types'

export const AuthContext = createContext({
  authenticated: null,
  setAuthenticated: () => {}
})

export function AuthProvider({ children }) {
  const [authentication, setAuthentication] = useState(false)
  const { token, expiration, setToken, setExpiration } = useAuthentication()

  const isAuthenticated = !!(token !== null && expiration > Date.now())

  useEffect(() => {
    if (isAuthenticated) {
      setAuthentication(true)
    } else {
      setToken(null)
      setExpiration(Date.now())
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <AuthContext.Provider
      value={{
        authenticated: authentication,
        setAuthenticated: setAuthentication,
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
