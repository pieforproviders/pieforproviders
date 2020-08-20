import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'

export function ActionLink({ onClick, text, classes }) {
  const handleClick = e => {
    e.preventDefault()
    onClick()
  }
  return (
    <>
      <Button
        onClick={handleClick}
        className={`${classes} focus:shadow-none`}
        type="link"
      >
        {text}
      </Button>
    </>
  )
}

ActionLink.propTypes = {
  onClick: PropTypes.func,
  text: PropTypes.string,
  classes: PropTypes.string
}
