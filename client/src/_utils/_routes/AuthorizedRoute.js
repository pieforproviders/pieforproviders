import React, { useMemo } from 'react'
import PropTypes from 'prop-types'
import { Redirect, Route } from 'react-router-dom'
import { LoggedInLayout } from '_shared'
import { useAuthToken } from '_shared/_hooks/useAuthToken'

export default function AuthorizedRoute({
  children,
  exact,
  path,
  title,
  // permissions,
  ...routeProps
}) {
  const [authToken] = useAuthToken()
  exact = !!exact
  const content = useMemo(() => {
    if (!authToken) {
      return <Redirect to="/login" />
      // TODO: Permissions & expired passwords?
      // } else if (SessionService.getNeedsPasswordChange()) {
      //   return <Redirect to="/expired-password" />
      // } else if (!PermissionService.can(...permissions)) {
      //   return <Redirect to="/" />
    } else {
      return children
    }
  }, [authToken, children])
  return (
    <Route exact={exact} path={path} {...routeProps}>
      <LoggedInLayout title={title}>{content}</LoggedInLayout>
    </Route>
  )
}

AuthorizedRoute.propTypes = {
  children: PropTypes.element.isRequired,
  exact: PropTypes.bool,
  path: PropTypes.string.isRequired,
  title: PropTypes.string
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
