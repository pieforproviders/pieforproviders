import React from 'react'
import PropTypes from 'prop-types'

import { Typography } from 'antd'

const { Title } = Typography

export function SectionMessage({
  appearance = 'info',
  title,
  children,
  centered
}) {
  const getBackgroundColorClass = () => {
    return 'bg-mediumGray'
  }

  const getContainerClass = () => {
    let containerClass = getBackgroundColorClass()
    if (centered) {
      containerClass = `${containerClass} text-center`
    }

    return containerClass
  }

  return (
    <div className={getContainerClass() + ' p-10 center'}>
      <Title level={2}>{title}</Title>
      {children}
    </div>
  )
}

SectionMessage.propTypes = {
  appearance: PropTypes.string,
  title: PropTypes.string,
  children: PropTypes.node,
  centered: PropTypes.bool
}
