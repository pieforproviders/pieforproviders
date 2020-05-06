import React, { useState, useEffect } from 'react'
import PropTypes from 'prop-types'
import ExpandMoreIcon from '@material-ui/icons/ExpandMore'
import ExpandLessIcon from '@material-ui/icons/ExpandLess'

/**
 * Custom dropdown input including a label, that accepts styling
 *
 * @param {boolean}  [combo]             Indicates if the dropdown is displayed individually or as a combo box with a text input.
 * @param {string}   [containerClasses]  Custom classes to be applied to the container div.
 * @param {string}   [defaultOption]     The value of the default option, if one should be set.
 * @param {string}   inputId             Unique identifier for a rendered component.
 * @param {string}   [labelClasses]      Custom classes to be applied to the label div.
 * @param {string}   [label]             The display text for the label div.
 * @param {func}     onChange            Callback to be triggered when the dropdown's selected option changes.
 * @param {string}   [optionClasses]     Custom classes to be applied to the "options" in the dropdown.
 * @param {Object[]} options             Array of options with a value (for direct comparison) and a label (for display).
 * @param {string}   [placeholder]       Placeholder text to display inside the dropdown select box.
 * @param {boolean}  [required]          Indicates whether or not the dropdowns's value is required.
 * @param {string}   [selectClasses]     Custom classes to be applied to the "select" box div.
 *
 */

export default function DropdownInput({
  combo,
  containerClasses,
  defaultOption,
  inputId,
  labelClasses,
  label,
  onChange,
  optionClasses,
  options,
  placeholder,
  required,
  selectClasses
}) {
  const [menuIsOpen, setMenuIsOpen] = useState(false)
  const [selectedOption, setSelectedOption] = useState(null)

  const containerClass = ['dropdown-input', containerClasses]
    .filter(item => !!item)
    .join(' ')

  const labelClass = [required && 'required-label', labelClasses]
    .filter(item => !!item)
    .join(' ')

  const selectClass = [
    selectedOption && 'item-selected',
    combo ? 'select-box-combo' : 'select-box-solo',
    selectClasses
  ]
    .filter(item => !!item)
    .join(' ')

  const optionClass = ['dropdown-option', optionClasses]
    .filter(item => !!item)
    .join(' ')

  const toggleMenuOnEnter = event => {
    event.key === 'Enter' && toggleMenu()
  }

  const toggleMenu = () => {
    setMenuIsOpen(!menuIsOpen)
  }

  const handleSelection = (option, event = null) => {
    if ((event && event.key === 'Enter') || !event) {
      setSelectedOption(option.value)
      onChange(option.value)
    }
  }

  useEffect(() => {
    if (menuIsOpen) {
      // close menu on page click
      document.addEventListener('click', toggleMenu)
    }

    return () => {
      // Unbind the event listener on clean up
      document.removeEventListener('click', toggleMenu)
    }
  })

  return (
    <div className={containerClass}>
      {label && (
        <div className={labelClass} id={`${inputId}-label`}>
          {label}
        </div>
      )}
      <div
        aria-labelledby={`${inputId}-label`}
        id={inputId}
        className={selectClass}
        onClick={toggleMenu}
        onKeyDown={event => toggleMenuOnEnter(event)}
        role="listbox"
        tabIndex="0"
      >
        <div className="dropdown-field">
          {selectedOption
            ? options &&
              options.find(option => option.value === selectedOption).label
            : defaultOption
            ? options &&
              options.find(option => option.value === defaultOption).label
            : placeholder || ''}
        </div>
        <div className="dropdown-icon">
          {menuIsOpen ? <ExpandLessIcon /> : <ExpandMoreIcon />}
        </div>
      </div>

      {menuIsOpen && (
        <div className="dropdown-list" role="list">
          {options &&
            options.map(option => (
              <div
                aria-selected={selectedOption === option.value}
                className={optionClass}
                key={option.label}
                onClick={() => handleSelection(option)}
                onKeyDown={event => {
                  handleSelection(option, event)
                  toggleMenuOnEnter(event)
                }}
                role="option"
                tabIndex="0"
              >
                {option.label}
              </div>
            ))}
        </div>
      )}
    </div>
  )
}

DropdownInput.propTypes = {
  combo: PropTypes.bool,
  containerClasses: PropTypes.string,
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
  selectClasses: PropTypes.string,
  required: PropTypes.bool
}
