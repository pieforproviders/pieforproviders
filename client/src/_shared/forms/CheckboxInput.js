import React from 'react'
import PropTypes from 'prop-types'
import ValidationError from '_shared/forms/ValidationError'

/**
 * Custom checkbox input including a label, that accepts styling
 *
 * @param {boolean} checked             The checkbox's checked state on render.
 * @param {string}  [containerClasses]  Custom classes to be applied to the container div.
 * @param {Object}  [errors]            Errors on the input, if any.
 * @param {string}  inputId             Unique identifier for a rendered component.
 * @param {string}  [inputClasses]      Custom classes to be applied to the "input" - the checkbox itself.
 * @param {string}  [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}  label               The display text for the label div.
 * @param {func}    onChange            Callback to be triggered when the checkbox's checked state changes.
 * @param {func}    [register]          Register for form validation with react-hook-form
 * @param {boolean} [required]          Indicates whether or not the checkbox's value is required.
 *
 */

export default function CheckboxInput({
  checked,
  containerClasses,
  errors,
  inputId,
  inputClasses,
  labelClasses,
  label,
  onChange,
  register,
  required
}) {
  const containerClass = ['checkbox-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const inputClass = [errors && 'error-input', inputClasses]
    .filter(item => !!item)
    .join(' ')

  return (
    <div className={containerClass}>
      <input
        checked={checked}
        className={inputClass}
        id={inputId}
        name={inputId}
        onChange={onChange}
        ref={register}
        type="checkbox"
      />
      <label htmlFor={inputId} className={labelClass}>
        {label}
      </label>
      {errors && <ValidationError errorMessage={errors.message} />}
    </div>
  )
}

CheckboxInput.propTypes = {
  checked: PropTypes.bool.isRequired,
  containerClasses: PropTypes.string,
  errors: PropTypes.object,
  inputClasses: PropTypes.string,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.oneOfType([PropTypes.string, PropTypes.element]).isRequired,
  onChange: PropTypes.func.isRequired,
  register: PropTypes.func,
  required: PropTypes.bool
}
