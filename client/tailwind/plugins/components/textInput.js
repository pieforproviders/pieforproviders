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
          '&.text-input-solo': {
            borderWidth: '1px'
          },
          '&.text-input-combo': {
            borderTopWidth: '1px',
            borderRightWidth: '1px',
            borderBottomWidth: '1px',
            borderLeftWidth: '0'
          },
          '&.error-input': {
            borderColor: theme('colors.red1')
          }
        }
      }
    }

    addComponents(textInput)
  }
}
