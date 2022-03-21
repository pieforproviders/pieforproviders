import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { useDispatch, useSelector } from 'react-redux'
import { Breadcrumb } from 'antd'
import useHotjar from 'react-use-hotjar'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { setUser } from '_reducers/userReducer'
import { Header } from '_shared'

export function LoggedInLayout({ children, title }) {
  const { identifyHotjar } = useHotjar()
  const { makeRequest } = useApiResponse()
  const dispatch = useDispatch()
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))

  useEffect(() => {
    const getUserData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/profile',
        headers: {
          Authorization: token
        }
      })

      if (response.ok) {
        const resp = await response.json()
        dispatch(setUser(resp))
        identifyHotjar(resp.id ?? null, resp, console.info)
      }
    }

    // user.full_name is the main required field for the profile page
    if (!user || !user.full_name) {
      getUserData()
    }

    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="bg-mediumGray h-full min-h-screen">
      <Header />
      <div className="w-full px-4 mt-4">
        {title && (
          <Breadcrumb className="mb-2">
            <Breadcrumb.Item>{title}</Breadcrumb.Item>
          </Breadcrumb>
        )}
        <div className="bg-white px-4 pb-6 pt-8 shadow-md rounded-sm">
          {children}
        </div>
      </div>
    </div>
  )
}

LoggedInLayout.propTypes = {
  children: PropTypes.element,
  title: PropTypes.string
}
