import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { Route } from 'react-router-dom'
import { LoggedInLayout } from '_shared'
import { useHistory } from 'react-router-dom'
import { isAuthenticated } from '_utils/isAuthenticated'

export default function AuthorizedRoute({
  contentComponent: ContentComponent,
  exact,
  path,
  title,
  // permissions,
  ...routeProps
}) {
  exact = !!exact
  let history = useHistory()

  useEffect(() => {
    !isAuthenticated() && history.push('/login')
  })

  return (
    <Route exact={exact} path={path} {...routeProps}>
      <LoggedInLayout title={title}>
        <ContentComponent />
      </LoggedInLayout>
    </Route>
  )
}

AuthorizedRoute.propTypes = {
  contentComponent: PropTypes.func.isRequired,
  exact: PropTypes.bool,
  path: PropTypes.string.isRequired,
  title: PropTypes.string
  // permissions: PropTypes.arrayOf(PropTypes.string)
}
