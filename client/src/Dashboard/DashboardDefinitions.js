import React from 'react'
import PropTypes from 'prop-types'
import NEDashboardDefintions from './NEDashboardDefinitions'
import ILDashboardDefintions from './ILDashboardDefinitions'
import '_assets/styles/tag-overrides.css'

export default function DashboardDefinitions({
  activeKey,
  setActiveKey,
  state
}) {
  return state === 'NE' ? (
    <NEDashboardDefintions activeKey={activeKey} setActiveKey={setActiveKey} />
  ) : (
    <ILDashboardDefintions activeKey={activeKey} setActiveKey={setActiveKey} />
  )
}

DashboardDefinitions.propTypes = {
  activeKey: PropTypes.number,
  setActiveKey: PropTypes.func,
  state: PropTypes.string
}
