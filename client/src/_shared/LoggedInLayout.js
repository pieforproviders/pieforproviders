import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { Breadcrumb } from 'antd'
import { Header } from '_shared'

export function LoggedInLayout({ children, title }) {
  useEffect(() => {
    window.MiniProfiler?.pageTransition()
  }, [])

  return (
    <div className="h-full min-h-screen bg-mediumGray">
      <Header />
      <div className="w-full px-4 mt-4">
        {title && (
          <Breadcrumb className="mb-2">
            <Breadcrumb.Item>{title}</Breadcrumb.Item>
          </Breadcrumb>
        )}
        <div className="px-4 pt-8 pb-6 bg-white rounded-sm shadow-md">
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
