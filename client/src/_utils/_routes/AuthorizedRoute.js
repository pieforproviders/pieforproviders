import React, { useMemo } from 'react'
import PropTypes from 'prop-types'
import { Redirect, Route } from 'react-router-dom'

export default function AuthorizedRoute({
  children,
  exact,
  path,
  // permissions,
  ...routeProps
}) {
  exact = !!exact
  const content = useMemo(() => {
    if (!localStorage.getItem('pie-token')) {
      return <Redirect to="/login" />
      // TODO: Permissions & expired passwords?
      // } else if (SessionService.getNeedsPasswordChange()) {
      //   return <Redirect to="/expired-password" />
      // } else if (!PermissionService.can(...permissions)) {
      //   return <Redirect to="/" />
    } else {
      return children
    }
  }, [children])
  return (
    <Route exact={exact} path={path} {...routeProps}>
      {content}
    </Route>
  )
}

AuthorizedRoute.propTypes = {
  path: PropTypes.string.isRequired,
  children: PropTypes.element.isRequired,
  exact: PropTypes.bool
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
