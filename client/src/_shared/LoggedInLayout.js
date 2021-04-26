import React from 'react'
import PropTypes from 'prop-types'
import { Breadcrumb } from 'antd'
import { Header } from '_shared'

export function LoggedInLayout({ children, title }) {
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
