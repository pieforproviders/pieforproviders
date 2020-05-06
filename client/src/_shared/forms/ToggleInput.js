import React, { useState } from 'react'
import PropTypes from 'prop-types'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'

/**
 * Custom toggle/radio input including a label, that accepts styling
 *
 * @param {string}   [containerClasses]  Custom classes to be applied to the container div.
 * @param {string}   [defaultOption]     The value of the default option to be selected on render.
 * @param {string}   inputId             Unique identifier for a rendered component.
 * @param {string}   [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}   label               The display text for the label div.
 * @param {func}     onChange            Callback to be triggered when the toggle's selected option changes.
 * @param {string}   [optionClasses]     Custom classes to be applied to the "options" in the option list.
 * @param {Object[]} options             Array of options with a value (for direct comparison) and a label (for display).
 * @param {boolean}  [required]          Indicates whether or not the dropdowns's value is required.
 * @param {string}   [selectClasses]     Custom classes to be applied to the "select" div of the option list.
 *
 */

export default function ToggleInput({
  containerClasses,
  defaultOption,
  inputId,
  labelClasses,
  label,
  onChange,
  optionClasses,
  options,
  required,
  selectClasses
}) {
  const [selectedOption, setSelectedOption] = useState(defaultOption)

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

  const handleSelect = option => {
    setSelectedOption(option.value)
    onChange(option.value)
  }

  return (
    <div className={containerClass}>
      <div className={labelClass} id={`${inputId}-label`}>
        {label}
      </div>
      <div className={selectClass}>
        {options &&
          options.map(option => (
            <div
              aria-labelledby={`${inputId}-label`}
              className={optionClass(option)}
              key={option.label}
              onClick={() => handleSelect(option)}
              onKeyDown={event => event.key === 'Enter' && handleSelect(option)}
              tabIndex="0"
            >
              {selectedOption && selectedOption === option.value ? (
                <CheckCircleIcon className="selected-check" />
              ) : (
                <RadioButtonUncheckedIcon className="unselected-check" />
              )}
              <span>{option.label}</span>
            </div>
          ))}
      </div>
    </div>
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
  required: PropTypes.bool
}
