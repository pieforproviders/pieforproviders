import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { Select as AntDSelect } from 'antd'

const Select = ({ id, name, children, onChange, ...extraProps }) => {
  const [value, setValue] = useState('')

  const handleOnChange = selectedValue => {
    setValue(selectedValue)
    onChange(selectedValue)
  }

  return (
    <>
      <input type="hidden" name={name} value={value} id={id} />
      <AntDSelect id={`antd-${id}`} onChange={handleOnChange} {...extraProps}>
        {children}
      </AntDSelect>
    </>
  )
}

Select.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string,
  extraProps: PropTypes.any,
  children: PropTypes.any,
  onChange: PropTypes.func
}

export default Select
const { Option } = AntDSelect
export { Option }
