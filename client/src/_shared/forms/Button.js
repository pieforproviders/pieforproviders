import React from 'react'
import PropTypes from 'prop-types'

/**
 * Custom submit button, that accepts styling
 *
 * @param {string}  [buttonClasses]     Custom classes to be applied to the button.
 * @param {boolean} [disabled]          Boolean for whether form is disabled or not.
 * @param {string}  label               The display text for the button.
 * @param {string}  [type=submit]       Type of button (i.e. submit).
 *
 */

export default function Button({
  buttonClasses,
  disabled,
  label,
  type = 'submit'
}) {
  return (
    <>
      <button className={buttonClasses} type={type} disabled={disabled}>
        {label}
      </button>
    </>
  )
}

Button.propTypes = {
  buttonClasses: PropTypes.string,
  disabled: PropTypes.bool,
  label: PropTypes.string.isRequired,
  type: PropTypes.string
}
