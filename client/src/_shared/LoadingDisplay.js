import React from 'react'
import pieWithSlice from '../_assets/pieWithSlice.png'
import { Progress } from 'antd'
import '_assets/styles/progress-bar-overrides.css'

export function LoadingDisplay() {
  return (
    <div>
      <div className="mt-4">
        <img className="m-auto" alt="pieWithSlice" src={pieWithSlice} />
      </div>
      <div className="my-5">
        <h3 className="h3-large">Loading...</h3>
      </div>
      <Progress
        className="table-loading"
        strokeColor={'#006C9E'}
        size="large"
        percent={55}
        showInfo={false}
      />
    </div>
  )
}
