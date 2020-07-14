import React from 'react'
import PropTypes from 'prop-types'
import piefulltanlogo from '_assets/piefulltanlogo.svg'

export function AuthLayout({ backgroundImageClass, rightColumnContent }) {
  return (
    <>
      <div
        className={`hidden h-screen block bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <div className="w-full px-4">
        {/* TODO: language switcher */}
        <p className="text-right">English</p>
        <img
          alt="Pie for Providers logo"
          src={piefulltanlogo}
          className="w-24 medium:w-48 mx-auto m-12"
        />
        <div className="text-center">{rightColumnContent()}</div>
      </div>
    </>
  )
}

AuthLayout.propTypes = {
  backgroundImageClass: PropTypes.string,
  rightColumnContent: PropTypes.func
}
