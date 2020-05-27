import React from 'react'
import PropTypes from 'prop-types'

/**
 * Custom dropdown input including a label, that accepts styling
 *
 * @param {boolean} [combo]             Indicates if the text input is displayed individually or as a combo box with a dropdown.
 * @param {string}  [containerClasses]  Custom classes to be applied to the container div.
 * @param {string}  inputId             Unique identifier for a rendered component.
 * @param {string}  [inputClasses]      Custom classes to be applied to the text input.
 * @param {string}  [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}  [label]             The display text for the label div.
 * @param {func}    onInput             Callback to be triggered when the text input's value changes.
 * @param {string}  [placeholder]       Placeholder text to display inside the text input.
 * @param {func}    [register]          Register for form validation with react-hook-form
 * @param {boolean} [required]          Indicates whether or not the text input's value is required.
 * @param {boolean} [type='text']       ype of input (e.g. email, tel, text, password, etc.)
 * @param {boolean} value               The text input's value state on render.
 *
 */
export default function TextInput({
  combo,
  containerClasses,
  inputId,
  inputClasses,
  labelClasses,
  label,
  onInput,
  placeholder,
  register,
  required,
  type = 'text',
  value
}) {
  const containerClass = ['text-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const inputClass = [
    combo ? 'text-input-combo' : 'text-input-solo',
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
        id={inputId}
        name={inputId}
        onInput={onInput}
        placeholder={placeholder}
        ref={register}
        type={type}
        defaultValue={value}
      />
    </div>
  )
}

TextInput.propTypes = {
  combo: PropTypes.bool,
  containerClasses: PropTypes.string,
  inputClasses: PropTypes.string,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.string,
  onInput: PropTypes.func.isRequired,
  placeholder: PropTypes.string.isRequired,
  register: PropTypes.func,
  required: PropTypes.bool,
  type: PropTypes.string,
  value: PropTypes.string
}
