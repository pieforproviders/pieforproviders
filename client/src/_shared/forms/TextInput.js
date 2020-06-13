import React from 'react'
import PropTypes from 'prop-types'
import ValidationError from '_shared/forms/ValidationError'

/**
 * Custom dropdown input including a label, that accepts styling
 *
 * @param {boolean} [comboSide]                 Indicates the side of a combo box the text input should be displayed on.
 * @param {string}  [containerClasses]          Custom classes to be applied to the container div.
 * @param {boolean} [defaultValue]              The text input's value state on render.
 * @param {Object}  [errors]                    Errors on the input, if any.
 * @param {string}  [inputClasses]              Custom classes to be applied to the text input.
 * @param {string}  inputId                     Unique identifier for a rendered component.
 * @param {string}  [labelClasses]              Custom classes to be applied to the label div.
 * @param {string}  [label]                     The display text for the label div.
 * @param {func}    [onBlur]                    Callback to be triggered when the user navigates away from the field.
 * @param {func}    [onInput]                   Callback to be triggered when the text input's value changes.
 * @param {string}  [placeholder]               Placeholder text to display inside the text input.
 * @param {func}    [register]                  Register for form validation with react-hook-form
 * @param {boolean} [required]                  Indicates whether or not the text input's value is required.
 * @param {boolean} [showValidationError=true]  Indicates whether or not to display validation error text (useful for combo boxes)
 * @param {boolean} [type='text']               Type of input (e.g. email, tel, text, password, etc.)
 *
 */

export default function TextInput({
  comboSide,
  containerClasses,
  defaultValue,
  errors,
  inputClasses,
  inputId,
  labelClasses,
  label,
  onInput,
  placeholder,
  register,
  required,
  showValidationError = true,
  type = 'text'
}) {
  const containerClass = ['text-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const inputClass = [
    errors && 'error-input',
    comboSide ? `text-input-combo-${comboSide}` : 'text-input-solo',
    inputClasses
  ]
    .filter(item => !!item)
    .join(' ')

  return (
    <div className={containerClass}>
      {label && (
        <label htmlFor={inputId} className={labelClass}>
          {label}
        </label>
      )}
      <input
        autoComplete={type === 'password' ? 'off' : 'on'}
        className={inputClass}
        defaultValue={defaultValue}
        id={inputId}
        name={inputId}
        onInput={onInput}
        placeholder={placeholder}
        ref={register}
        type={type}
      />
      {errors && showValidationError && (
        <ValidationError errorMessage={errors.message} />
      )}
    </div>
  )
}

TextInput.propTypes = {
  comboSide: PropTypes.string,
  containerClasses: PropTypes.string,
  defaultValue: PropTypes.string,
  errors: PropTypes.object,
  inputClasses: PropTypes.string,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.string,
  onBlur: PropTypes.func,
  onInput: PropTypes.func,
  placeholder: PropTypes.string,
  register: PropTypes.func,
  required: PropTypes.bool,
  showValidationError: PropTypes.bool,
  type: PropTypes.string
}
