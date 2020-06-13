import React from 'react'
import ErrorOutlineIcon from '@material-ui/icons/ErrorOutline'
import PropTypes from 'prop-types'

/**
 * Custom form validation error message
 *
 * @param {string}  errorMessage     Message to display to the user on error.
 *
 */

export default function ValidationError({ errorMessage }) {
  return (
    <div className="text-red1 font-semibold mt-2">
      <ErrorOutlineIcon fontSize="inherit" /> {errorMessage}
    </div>
  )
}

ValidationError.propTypes = {
  errorMessage: PropTypes.string.isRequired
}
