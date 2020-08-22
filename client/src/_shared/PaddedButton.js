import React from 'react'
import { Button } from 'antd'

export function PaddedButton({
  type = 'primary',
  shape = 'round',
  size = 'middle',
  htmlType = 'submit',
  classes = '',
  text = 'Submit'
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
