module.exports = function() {
  return function({ addBase, config }) {
    const baseStyles = {
      html: {
        fontSize: '100%'
      },
      '*:focus': {
        outline: '0',
        boxShadow: `0 0 4px 0 ${config('theme.colors.primaryBlue')}`
      },
      a: {
        color: config('theme.colors.primaryBlue'),
        textDecoration: 'underline'
      }
    }
    addBase(baseStyles)
  }
}
