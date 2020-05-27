// following the 1 shared component == 1 tailwind component plugin pattern

module.exports = function() {
  return function({ addComponents, theme }) {
    const toggleInput = {
      '.toggle-input': {
        '.toggle-options': {
          display: 'grid',
          '& > *': {
            verticalAlign: 'middle'
          },
          '& > div': {
            borderColor: theme('colors.primaryBlue'),
            borderStyle: 'solid',
            borderWidth: '1px 1px 1px 0',
            borderRadius: '0',
            padding: '0.75rem 0',
            textAlign: 'center',
            color: theme('colors.gray4'),
            '&:first-child': {
              borderWidth: '1px'
            },
            '& > .selected-check > svg': {
              color: theme('colors.primaryBlue')
            },
            '&.toggle-selected': {
              backgroundColor: theme('colors.blue3')
            },
            '&.toggle-option': {
              '&:focus-within': {
                outline: '0',
                boxShadow: `0 0 4px 0 ${theme('colors.primaryBlue')}`
              },
              '& > label': {
                display: 'inline-block',
                marginLeft: '-15px',
                fontSize: '0.875rem',
                '& > svg': {
                  fontSize: '1rem',
                  marginRight: '0.5rem'
                },
                '& > span': {
                  display: 'inline-block',
                  verticalAlign: 'middle'
                }
              },
              '& > input': {
                opacity: 0,
                '&:focus': {
                  outline: '0',
                  border: '0'
                }
              }
            }
          }
        }
      }
    }

    addComponents(toggleInput)
  }
}
