import React from 'react'
import PropTypes from 'prop-types'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import ValidationError from '_shared/forms/ValidationError'

/**
 * Custom toggle/radio input including a label, that accepts styling
 *
 * @param {string}   [containerClasses]  Custom classes to be applied to the container div.
 * @param {Object}   [errors]            Errors on the input, if any.
 * @param {string}   inputId             Unique identifier for a rendered component.
 * @param {string}   [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}   label               The display text for the label div.
 * @param {func}     onChange            Callback to be triggered when the toggle's selected option changes.
 * @param {string}   [optionClasses]     Custom classes to be applied to the "options" in the option list.
 * @param {Object[]} options             Array of options with a value (for direct comparison) and a label (for display).
 * @param {func}     [register]          Register for form validation with react-hook-form
 * @param {boolean}  [required]          Indicates whether or not the dropdowns's value is required.
 * @param {string}   [selectClasses]     Custom classes to be applied to thee parent div. This should include `grid-cols-X` for the number of button columns you want in the radio box.
 * @param {string}   [selectedOption]    The value that is currently selected for this radio element.
 *
 */

export default function ToggleInput({
  containerClasses,
  errors,
  inputId,
  labelClasses,
  label,
  onChange,
  optionClasses,
  options,
  register,
  required,
  selectClasses,
  selectedOption
}) {
  const containerClass = ['toggle-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const optionClass = option => {
    return [
      selectedOption && selectedOption === option.value && 'toggle-selected',
      'toggle-option',
      optionClasses
    ]
      .filter(item => !!item)
      .join(' ')
  }

  const selectClass = [errors && 'error-input', 'toggle-options', selectClasses]
    .filter(item => !!item)
    .join(' ')

  return (
    <fieldset className={containerClass}>
      <legend className={labelClass}>{label}</legend>
      <div className={selectClass}>
        {options &&
          options.map(option => (
            <div key={option.label} className={optionClass(option)}>
              <input
                checked={selectedOption === option.value}
                id={option.value}
                name={inputId}
                onChange={onChange}
                ref={register}
                tabIndex="0"
                type="radio"
                value={option.value}
              />
              <label
                htmlFor={option.value}
                className={
                  selectedOption && selectedOption === option.value
                    ? 'selected-check'
                    : 'unselected-check'
                }
              >
                {selectedOption && selectedOption === option.value ? (
                  <CheckCircleIcon />
                ) : (
                  <RadioButtonUncheckedIcon />
                )}
                <span>{option.label}</span>
              </label>
            </div>
          ))}
      </div>
      {errors && <ValidationError errorMessage={errors.message} />}
    </fieldset>
  )
}

ToggleInput.propTypes = {
  containerClasses: PropTypes.string,
  errors: PropTypes.object,
  inputId: PropTypes.string.isRequired,
  labelClasses: PropTypes.string,
  label: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  optionClasses: PropTypes.string,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired
    })
  ).isRequired,
  register: PropTypes.func,
  required: PropTypes.bool,
  selectClasses: PropTypes.string,
  selectedOption: PropTypes.string
}
