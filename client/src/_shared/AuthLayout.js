import React from 'react'
import PropTypes from 'prop-types'
import { Col, Row } from 'antd'
import piefulltanlogo from '_assets/piefulltanlogo.svg'

export function AuthLayout({ backgroundImageClass, rightColumnContent }) {
  return (
    <Row>
      <Col
        xs={{ span: 0 }}
        lg={{ span: 12 }}
        className={`h-screen block bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <Col lg={{ span: 12 }}>
        {/* TODO: language switcher */}
        <p>English</p>
        <img
          alt="Pie for Providers logo"
          src={piefulltanlogo}
          className="w-24 medium:w-48 mx-auto"
        />
        {rightColumnContent()}
      </Col>
    </Row>
  )
}

AuthLayout.propTypes = {
  backgroundImageClass: PropTypes.string,
  rightColumnContent: PropTypes.element
}
