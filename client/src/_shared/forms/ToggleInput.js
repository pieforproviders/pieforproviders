import React from 'react'
import PropTypes from 'prop-types'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'

/**
 * Custom toggle/radio input including a label, that accepts styling
 *
 * @param {boolean}  checked             The toggle's checked state on render.
 * @param {string}   [containerClasses]  Custom classes to be applied to the container div.
 * @param {string}   [defaultOption]     The value of the default option to be selected on render.
 * @param {string}   inputId             Unique identifier for a rendered component.
 * @param {string}   [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}   label               The display text for the label div.
 * @param {func}     onChange            Callback to be triggered when the toggle's selected option changes.
 * @param {string}   [optionClasses]     Custom classes to be applied to the "options" in the option list.
 * @param {Object[]} options             Array of options with a value (for direct comparison) and a label (for display).
 * @param {func}     [register]          Register for form validation with react-hook-form
 * @param {boolean}  [required]          Indicates whether or not the dropdowns's value is required.
 * @param {string}   [selectClasses]     Custom classes to be applied to the "select" div of the option list.
 *
 */

export default function ToggleInput({
  containerClasses,
  inputId,
  labelClasses,
  label,
  onChange,
  optionClasses,
  options,
  register,
  required,
  selectedOption,
  selectClasses
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

  const selectClass = ['toggle-options', selectClasses]
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
                onChange={() => onChange(option.value)}
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
    </fieldset>
  )
}

ToggleInput.propTypes = {
  containerClasses: PropTypes.string,
  defaultOption: PropTypes.string,
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
  selectClasses: PropTypes.string,
  selectedOption: PropTypes.string,
  register: PropTypes.func,
  required: PropTypes.bool
}
