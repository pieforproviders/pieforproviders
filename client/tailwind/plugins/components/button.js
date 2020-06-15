module.exports = function() {
  return function({ addComponents, theme }) {
    const button = {
      'button.submit': {
        borderRadius: '34px',
        backgroundColor: theme('colors.primaryBlue'),
        color: theme('colors.white'),
        textTransform: 'uppercase',
        height: '3.1875rem',
        width: '11.25rem',
        '&:disabled, &[disabled]': {
          backgroundColor: theme('colors.gray5'),
          color: theme('colors.black'),
          cursor: 'default'
        }
      }
    }

    addComponents(button)
  }
}
