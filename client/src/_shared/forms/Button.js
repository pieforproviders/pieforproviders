import React from 'react'
import PropTypes from 'prop-types'

/**
 * Custom submit button, that accepts styling
 *
 * @param {string}  [buttonClasses]     Custom classes to be applied to the button.
 * @param {Object}  [errors]            Errors for the form, if any.
 * @param {string}  label               The display text for the button.
 * @param {string}  [type]              Type of button (i.e. submit)
 *
 */

export default function Button({ buttonClasses, errors, label, type }) {
  return (
    <>
      <button className={buttonClasses} type={type} disabled={!!errors}>
        {label}
      </button>
    </>
  )
}

Button.propTypes = {
  buttonClasses: PropTypes.string,
  errors: PropTypes.object,
  label: PropTypes.string.isRequired,
  type: PropTypes.string
}
