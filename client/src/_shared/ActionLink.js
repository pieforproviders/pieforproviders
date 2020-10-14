import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'

export function ActionLink({ onClick, text = '', classes = '', children }) {
  const handleClick = e => {
    e.preventDefault()
    onClick()
  }
  return (
    <>
      <Button onClick={handleClick} className={`${classes} mt-1`} type="link">
        {text || children}
      </Button>
    </>
  )
}

ActionLink.propTypes = {
  onClick: PropTypes.func.isRequired,
  text: PropTypes.string,
  children: PropTypes.node,
  classes: PropTypes.string
}
