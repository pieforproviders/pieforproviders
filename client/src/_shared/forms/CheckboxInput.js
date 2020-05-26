import React from 'react'
import PropTypes from 'prop-types'

/**
 * Custom checkbox input including a label, that accepts styling
 *
 * @param {boolean} checked             The checkbox's checked state on render.
 * @param {string}  [containerClasses]  Custom classes to be applied to the container div.
 * @param {string}  inputId             Unique identifier for a rendered component.
 * @param {string}  [inputClasses]      Custom classes to be applied to the "input" - the checkbox itself.
 * @param {string}  [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}  label               The display text for the label div.
 * @param {func}    onChange            Callback to be triggered when the checkbox's checked state changes.
 * @param {boolean} [required]          Indicates whether or not the checkbox's value is required.
 *
 */

export default function CheckboxInput({
  checked,
  containerClasses,
  inputId,
  inputClasses,
  labelClasses,
  label,
  onChange,
  required
}) {
  const containerClass = ['checkbox-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  return (
    <div className={containerClass}>
      <input
        checked={checked}
        className={inputClasses}
        id={inputId}
        onChange={onChange}
        onKeyDown={event => event.key === 'Enter' && onChange()}
        type="checkbox"
      />
      <label htmlFor={inputId} className={labelClass}>
        {label}
      </label>
    </div>
  )
}

CheckboxInput.propTypes = {
  checked: PropTypes.bool.isRequired,
  containerClasses: PropTypes.string,
  inputClasses: PropTypes.string,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.oneOfType([PropTypes.string, PropTypes.element]).isRequired,
  onChange: PropTypes.func.isRequired,
  required: PropTypes.bool
}
