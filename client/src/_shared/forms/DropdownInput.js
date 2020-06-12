import React from 'react'
import PropTypes from 'prop-types'
import ValidationError from '_shared/forms/ValidationError'

/**
 * Custom dropdown input including a label, that accepts styling
 *
 * @param {boolean}  [comboSide]                 Indicates the side of a combo box the dropdown input should be displayed on.
 * @param {string}   [containerClasses]          Custom classes to be applied to the container div.
 * @param {string}   [defaultValue]              The initial value of the dropdown
 * @param {Object}   [errors]                    Errors on the input, if any.
 * @param {string}   inputId                     Unique identifier for a rendered component.
 * @param {string}   [labelClasses]              Custom classes to be applied to the label div.
 * @param {string}   [label]                     The display text for the label div.
 * @param {func}     onChange                    Callback to be triggered when the dropdown's selected option changes.
 * @param {Object[]} options                     Array of options with a value (for direct comparison) and a label (for display).
 * @param {string}   [placeholder]               Placeholder text to display inside the dropdown select box.
 * @param {func}     [register]                  Register for form validation with react-hook-form
 * @param {boolean}  [showValidationError=true]  Indicates whether or not to display validation error text (useful for combo boxes)
 * @param {boolean}  [required]                  Indicates whether or not the dropdowns's value is required.
 * @param {string}   [selectClasses]             Custom classes to be applied to the "select" box div.
 *
 */

export default function DropdownInput({
  comboSide,
  containerClasses,
  defaultValue,
  errors,
  inputId,
  labelClasses,
  label,
  onChange,
  options,
  placeholder,
  register,
  required,
  selectClasses,
  showValidationError = true
}) {
  const containerClass = ['dropdown-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const selectClass = [
    errors && 'error-input',
    comboSide ? `select-box-combo-${comboSide}` : 'select-box-solo',
    selectClasses
  ]
    .filter(item => !!item)
    .join(' ')

  return (
    <div className={containerClass}>
      {label && (
        <label className={labelClass} htmlFor={inputId}>
          {label}
        </label>
      )}
      <select
        name={inputId}
        onChange={onChange}
        className={selectClass}
        ref={register}
        defaultValue={defaultValue}
        // defaultValue makes this an uncontrolled component, but I need to
        // timebox this so we'll come up with another solution if we need
        // a controlled select
      >
        {placeholder && (
          <option default value="">
            {placeholder}
          </option>
        )}
        {options &&
          options.map(option => (
            <option value={option.value} key={option.label}>
              {option.label}
            </option>
          ))}
      </select>
      {errors && showValidationError && (
        <ValidationError errorMessage={errors.message} />
      )}
    </div>
  )
}

DropdownInput.propTypes = {
  comboSide: PropTypes.string,
  containerClasses: PropTypes.string,
  defaultValue: PropTypes.string,
  errors: PropTypes.object,
  defaultOption: PropTypes.string,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  optionClasses: PropTypes.string,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired
    })
  ).isRequired,
  placeholder: PropTypes.string,
  register: PropTypes.func,
  required: PropTypes.bool,
  selectClasses: PropTypes.string,
  showValidationError: PropTypes.bool
}
