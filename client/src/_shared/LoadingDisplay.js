import React from 'react'
import pieWithSlice from '../_assets/pieWithSlice.png'
import '_assets/styles/progress-bar-overrides.css'

export function LoadingDisplay() {
  return (
    <div>
      <img
        className="m-auto animate-spin"
        alt="pieWithSlice"
        src={pieWithSlice}
      />
      <div className="my-7">
        <h3 className="h2-large">Loading...</h3>
      </div>
    </div>
  )
}
