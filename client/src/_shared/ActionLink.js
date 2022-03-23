import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'

export function ActionLink({
  onClick,
  text = '',
  classes = '',
  children,
  href
}) {
  const handleClick = e => {
    e.preventDefault()
    onClick()
  }
  return (
    <>
      <Button
        onClick={!href ? handleClick : undefined}
        href={href}
        className={`${classes} mt-1`}
        type="link"
      >
        {text || children}
      </Button>
    </>
  )
}

ActionLink.propTypes = {
  onClick: PropTypes.func,
  text: PropTypes.string,
  children: PropTypes.node,
  classes: PropTypes.string,
  href: PropTypes.string
}
