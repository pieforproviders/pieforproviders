import * as React from 'react'
import DatePicker from '../Dashboard/DatePicker'

export const TimePicker = React.forwardRef((props, ref) => {
  return React.createElement(
    DatePicker,
    Object.assign({}, props, { picker: 'time', mode: undefined, ref: ref })
  )
})

TimePicker.displayName = 'TimePicker'
