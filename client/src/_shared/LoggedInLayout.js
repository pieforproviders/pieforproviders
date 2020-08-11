import React from 'react'
import PropTypes from 'prop-types'
import pieSliceLogo from '_assets/pieSliceLogo.svg'
import '_assets/styles/layouts.css'
import MenuIcon from '@material-ui/icons/Menu'

export function LoggedInLayout({ children, title }) {
  return (
    <div className="">
      <div className="w-full shadow p-4 flex items-center ">
        <img
          alt="Pie for Providers logo"
          src={pieSliceLogo}
          className="w-8 mr-2"
        />{' '}
        <div className="text-2xl font-semibold flex-grow">
          Pie for Providers
        </div>
        <MenuIcon style={{ fontSize: '36px' }} />
      </div>
      <div className="w-full bg-mediumGray p-4">
        {title && <div className="text-black text-sm mb-2">{title}</div>}
        <div className="bg-white px-4 pb-6 pt-8 shadow rounded-sm">
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
