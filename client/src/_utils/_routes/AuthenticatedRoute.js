import React from 'react'
import PropTypes from 'prop-types'
import { useNavigate } from 'react-router-dom'
import { LoggedInLayout } from '_shared'
import { useAuthentication } from '_shared/_hooks/useAuthentication'

export default function AuthenticatedRoute({
  children,
  title,
  // permissions,
  ...routeProps
}) {
  const isAuthenticated = useAuthentication()
  const navigate = useNavigate()
  if (!isAuthenticated) {
    navigate('/login')
    // TODO: Permissions & expired passwords?
    // } else if (SessionService.getNeedsPasswordChange()) {
    //   return <Redirect to="/expired-password" />
    // } else if (!PermissionService.can(...permissions)) {
    //   return <Redirect to="/" />
  } else {
    return <LoggedInLayout title={title}>{children}</LoggedInLayout>
  }
}

AuthenticatedRoute.propTypes = {
  children: PropTypes.element.isRequired,
  title: PropTypes.string
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
