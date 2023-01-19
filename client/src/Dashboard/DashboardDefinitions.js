import React from 'react'
import PropTypes from 'prop-types'
import NEDashboardDefinitions from './NEDashboardDefinitions'
import ILDashboardDefinitions from './ILDashboardDefinitions'
import '_assets/styles/tag-overrides.css'

export default function DashboardDefinitions({
  activeKey,
  setActiveKey,
  state
}) {
  return state === 'NE' ? (
    <NEDashboardDefinitions activeKey={activeKey} setActiveKey={setActiveKey} />
  ) : (
    <ILDashboardDefinitions activeKey={activeKey} setActiveKey={setActiveKey} />
  )
}

DashboardDefinitions.propTypes = {
  activeKey: PropTypes.number,
  setActiveKey: PropTypes.func,
  state: PropTypes.string
}
