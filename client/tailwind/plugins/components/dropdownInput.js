// following the 1 shared component == 1 tailwind component plugin pattern

module.exports = function() {
  return function({ addComponents, theme }) {
    const dropdownInput = {
      '.dropdown-input': {
        position: 'relative',
        // we're using divs as labels and dropdowns, and we programmatically
        // give the label div ${inputId}-label as an ID; this way we can style
        // them no matter what input they belong to, and without giving them
        // arbitrary class names for semantics
        '[id$="-label"]': {
          display: 'block'
        },
        'div[role=listbox]': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          lineHeight: '1rem',
          borderRadius: '0',
          display: 'grid',
          gridTemplateColumns: 'auto 1rem',
          width: '100%',
          padding: '0.75rem 1rem',
          color: theme('colors.darkGray'),
          '&.item-selected': {
            color: theme('colors.primaryBlue')
          },
          '&.select-box-solo': {
            borderWidth: '1px'
          },
          '&.select-box-combo': {
            backgroundColor: theme('colors.blue3'),
            borderTopWidth: '1px',
            borderRightWidth: '0',
            borderBottomWidth: '1px',
            borderLeftWidth: '1px'
          },
          '&.error-input': {
            borderColor: theme('colors.red1')
          }
        },
        '.dropdown-field': {
          '&, & > *': {
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis'
          }
        },
        '.dropdown-icon': {
          color: theme('colors.primaryBlue'),
          height: '1rem',
          marginTop: '-0.25rem'
        },
        '.dropdown-list': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderWidth: '1px',
          position: 'absolute',
          width: '100%',
          marginTop: '-1rem',
          backgroundColor: theme('colors.white'),
          zIndex: '10',
          '.dropdown-option': {
            padding: '1rem',
            lineHeight: '1rem',
            '&:active, &:focus, &:hover': {
              backgroundColor: theme('colors.blue4')
            }
          }
        }
      }
    }

    addComponents(dropdownInput)
  }
}
