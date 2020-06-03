module.exports = function() {
  return function({ addComponents, theme }) {
    const textInput = {
      '.text-input': {
        label: {
          display: 'block'
        },
        '::placeholder': {
          color: theme('colors.gray3')
        },
        input: {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          lineHeight: '1rem',
          color: theme('colors.gray1'),
          display: 'block',
          padding: '0.75rem 1rem',
          width: '100%',
          borderWidth: '1px',
          '&.text-input-combo-right, &.text-input-combo-left': {
            height: '2.75rem'
          },
          '&.error-input': {
            borderColor: theme('colors.red1'),
            '&.text-input-combo-right, &.text-input-combo-left': {
              borderTop: `1px solid ${theme('colors.red1')}`,
              borderBottom: `1px solid ${theme('colors.red1')}`
            },
            '&.text-input-combo-right': {
              borderLeft: `1px solid ${theme('colors.primaryBlue')}`,
              borderRight: `1px solid ${theme('colors.red1')}`
            },
            '&.text-input-combo-left': {
              borderRight: `1px solid ${theme('colors.primaryBlue')}`,
              borderLeft: `1px solid ${theme('colors.red1')}`
            }
          }
        }
      }
    }

    addComponents(textInput)
  }
}
