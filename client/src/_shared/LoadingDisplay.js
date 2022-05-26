import React from 'react'
import slicedPie from '../_assets/slicedPieTransparent.png'
import '_assets/styles/loading-spin.css'
import '_assets/styles/progress-bar-overrides.css'

export function LoadingDisplay() {
  return (
    <div>
      <img className="m-auto loading-spin" alt="pieWithSlice" src={slicedPie} />
      <div className="my-7">
        <h3 className="h2-large">Loading...</h3>
      </div>
    </div>
  )
}
