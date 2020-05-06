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
        '.text-input-solo': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderWidth: '1px',
          lineHeight: '1rem',
          color: theme('colors.gray1'),
          display: 'block',
          padding: '0.75rem 1rem',
          width: '100%'
        },
        '.text-input-combo': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderTopWidth: '1px',
          borderRightWidth: '1px',
          borderBottomWidth: '1px',
          borderLeftWidth: '0',
          lineHeight: '1rem',
          color: theme('colors.gray1'),
          display: 'block',
          padding: '0.75rem 1rem',
          width: '100%'
        }
      }
    }

    addComponents(textInput)
  }
}
