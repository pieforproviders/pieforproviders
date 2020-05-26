// following the 1 shared component == 1 tailwind component plugin pattern

module.exports = function() {
  return function({ addComponents, theme }) {
    const toggleInput = {
      '.toggle-input': {
        // we're using divs as labels and dropdowns, and we programmatically
        // give the label div ${inputId}-label as an ID; this way we can style
        // them no matter what input they belong to, and without giving them
        // arbitrary class names for semantics
        '[id$="-label"]': {
          display: 'block'
        },
        '.toggle-options': {
          display: 'grid'
        },
        '.toggle-option': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderWidth: '1px 1px 1px 0',
          borderRadius: '0',
          padding: '0.75rem 0',
          textAlign: 'center',
          color: theme('colors.gray1'),
          '& > *': {
            verticalAlign: 'middle'
          },
          '&:first-child': {
            borderWidth: '1px'
          },
          '& > .selected-check, & > .unselected-check': {
            fontSize: '0.875rem',
            marginRight: '0.25rem'
          },
          '& > .selected-check': {
            color: theme('colors.primaryBlue')
          },
          '&.toggle-selected': {
            backgroundColor: theme('colors.blue3'),
            color: theme('colors.gray2')
          }
        }
      }
    }

    addComponents(toggleInput)
  }
}
