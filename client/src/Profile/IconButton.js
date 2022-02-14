import React from 'react'
import PropTypes from 'prop-types'

const IconButton = ({ icon, text, onClick, className }) => {
  const inheritedClasses = className + ' ' || ''
  return (
    <button
      className={
        inheritedClasses +
        'text-primaryBlue focus:outline-none hover:underline p-2 pl-0'
      }
      type="text"
      onClick={onClick}
    >
      {React.cloneElement(icon, {
        style: { fontSize: '1.125rem' },
        viewBox: '0 1 24 24'
      })}
      <span className="ml-1 font-bold">{text}</span>
    </button>
  )
}

IconButton.propTypes = {
  icon: PropTypes.node.isRequired,
  text: PropTypes.string,
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string
}

export default IconButton
