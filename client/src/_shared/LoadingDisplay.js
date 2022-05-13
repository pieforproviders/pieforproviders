import React from 'react'
import pieWithSlice from '../_assets/pieWithSlice.png'
import { Progress } from 'antd'
import { useSelector } from 'react-redux'
import '_assets/styles/progress-bar-overrides.css'

export function LoadingDisplay() {
  const percentage = useSelector(state => state.ui.progress?.percentage || 0)

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
        percent={percentage}
        showInfo={false}
      />
    </div>
  )
}
