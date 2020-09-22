import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { Route } from 'react-router-dom'
import { LoggedInLayout } from '_shared'
import { useHistory } from 'react-router-dom'
import useAuthentication from '_shared/_hooks/useAuthentication'

export default function AuthenticatedRoute({
  contentComponent: ContentComponent,
  exact,
  path,
  title,
  // permissions,
  ...routeProps
}) {
  exact = !!exact
  let history = useHistory()
  const { isAuthenticated } = useAuthentication

  useEffect(() => {
    !isAuthenticated && history.push('/login')
  })

  return (
    <Route exact={exact} path={path} {...routeProps}>
      <LoggedInLayout title={title}>
        <ContentComponent />
      </LoggedInLayout>
    </Route>
  )
}

AuthenticatedRoute.propTypes = {
  contentComponent: PropTypes.func.isRequired,
  exact: PropTypes.bool,
  path: PropTypes.string.isRequired,
  title: PropTypes.string
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
