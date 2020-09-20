import React, { useContext, useMemo } from 'react'
import PropTypes from 'prop-types'
import { Redirect, Route } from 'react-router-dom'
import { LoggedInLayout } from '_shared'
import { AuthContext } from '_contexts/AuthContext'

export default function AuthorizedRoute({
  component: Component,
  exact,
  path,
  title,
  // permissions,
  ...routeProps
}) {
  exact = !!exact
  const {
    authenticated,
    setAuthenticated,
    userToken,
    setUserToken,
    tokenExpiration,
    setTokenExpiration
  } = useContext(AuthContext)
  const content = useMemo(() => {
    if (!authenticated) {
      return <Redirect to="/login" />
      // TODO: Permissions & expired passwords?
      // } else if (SessionService.getNeedsPasswordChange()) {
      //   return <Redirect to="/expired-password" />
      // } else if (!PermissionService.can(...permissions)) {
      //   return <Redirect to="/" />
    } else {
      return (
        <Component
          authenticated={authenticated}
          setAuthenticated={setAuthenticated}
          userToken={userToken}
          setUserToken={setUserToken}
          tokenExpiration={tokenExpiration}
          setTokenExpiration={setTokenExpiration}
        />
      )
    }
  }, [
    authenticated,
    setAuthenticated,
    userToken,
    setUserToken,
    tokenExpiration,
    setTokenExpiration
  ])
  return (
    <Route exact={exact} path={path} {...routeProps}>
      <LoggedInLayout
        title={title}
        setAuthenticated={setAuthenticated}
        setUserToken={setUserToken}
        setTokenExpiration={setTokenExpiration}
      >
        {content}
      </LoggedInLayout>
    </Route>
  )
}

AuthorizedRoute.propTypes = {
  component: PropTypes.element.isRequired,
  exact: PropTypes.bool,
  path: PropTypes.string.isRequired,
  title: PropTypes.string
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
