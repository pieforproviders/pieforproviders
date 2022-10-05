import React, { useEffect } from 'react'
import PropTypes from 'prop-types'
import { Select as AntDSelect } from 'antd'
import addNameAttributeToSelectById from '_utils/htmlHelper'

const Select = ({ id, name, children, ...extraProps }) => {
  useEffect(() => {
    addNameAttributeToSelectById(id, name)
  }, [id, name])

  return (
    <AntDSelect id={id} {...extraProps}>
      {children}
    </AntDSelect>
  )
}

Select.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string,
  extraProps: PropTypes.any,
  children: PropTypes.any
}

export default Select
const { Option } = AntDSelect
export { Option }
