import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { Breadcrumb } from 'antd'
import { Header } from '_shared'
import useHotjar from 'react-use-hotjar'
import { useDispatch, useSelector } from 'react-redux'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { setUser } from '_reducers/userReducer'

export function LoggedInLayout({ children, title }) {
  const { makeRequest } = useApiResponse()
  const dispatch = useDispatch()
  const { identifyHotjar } = useHotjar()
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
        /* setSummaryTotals(
          summaryDataTotalsConfig[`${resp.state === 'NE' ? 'ne' : 'default'}`]
        ) */
      }
    }
    if (Object.keys(user).length === 0) {
      getUserData()
    }
  }, [user])
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
