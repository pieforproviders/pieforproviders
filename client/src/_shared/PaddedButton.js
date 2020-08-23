import React from 'react'
import PropTypes from 'prop-types'
import { Button } from 'antd'

export function PaddedButton({
  type = 'primary',
  shape = 'round',
  size = 'middle',
  htmlType = 'submit',
  classes = '',
  text
}) {
  return (
    <Button
      type={type}
      shape={shape}
      size={size}
      htmlType={htmlType}
      className={`${
        classes ? classes : ''
      } py-4 px-8 h-auto w-auto font-semibold uppercase`}
    >
      {text}
    </Button>
  )
}

PaddedButton.propTypes = {
  type: PropTypes.string,
  text: PropTypes.string.isRequired,
  classes: PropTypes.string,
  shape: PropTypes.string,
  size: PropTypes.string,
  htmlType: PropTypes.string
}
