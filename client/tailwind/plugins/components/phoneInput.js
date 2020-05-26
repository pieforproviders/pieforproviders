module.exports = function() {
  return function({ addComponents, theme }) {
    const phoneInput = {
      '.phone-input': {
        label: {
          display: 'block'
        },
        '.phone-input-solo': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderWidth: '1px',
          borderRadius: '0',
          display: 'grid',
          gridTemplateColumns: 'auto 1rem',
          padding: '0.75rem 1rem',
          width: '100%',
          color: theme('colors.gray3')
        },
        '.phone-input-combo': {
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderTopWidth: '1px',
          borderRightWidth: '1px',
          borderBottomWidth: '1px',
          borderLeftWidth: '0',
          borderRadius: '0',
          display: 'grid',
          gridTemplateColumns: 'auto 1rem',
          padding: '0.75rem 1rem',
          width: '100%',
          color: theme('colors.gray3')
        }
      }
    }

    addComponents(phoneInput)
  }
}
