import React from 'react'
import PropTypes from 'prop-types'
import pieFullTanLogo from '_assets/pieFullTanLogo.svg'
import '_assets/styles/layouts.css'

export function AuthLayout({
  backgroundImageClass,
  contentComponent: ContentComponent
}) {
  return (
    <div className="grid grid-cols-1 medium:grid-cols-8 large:grid-cols-2 h-screen">
      <div
        className={`hidden large:block h-screen block bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <div className="w-full medium:col-span-8 large:col-auto px-4 medium:px-8 overflow-y-scroll mt-8">
        {/* TODO: language switcher */}
        <p className="text-right">English</p>
        <div className="text-center large:text-left large:col-span-3 medium:grid medium:grid-cols-8 large:grid-cols-6">
          <div className="medium:col-start-3 medium:col-span-4 large:col-span-4">
            <img
              alt="Pie for Providers logo"
              src={pieFullTanLogo}
              className="w-24 medium:w-48 mt-0 mb-8 medium:mb-16 large:mb-12 mx-auto"
            />
            <ContentComponent />
          </div>
        </div>
      </div>
    </div>
  )
}

AuthLayout.propTypes = {
  backgroundImageClass: PropTypes.string,
  contentComponent: PropTypes.func
}
