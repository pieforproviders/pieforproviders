module.exports = function () {
  return function ({ addBase, config }) {
    const baseStyles = {
      '*:focus': {
        outline: '0',
        boxShadow: `0 0 4px 0 ${config('theme.colors.primaryBlue')}`
      },
      a: {
        fontSize: '100%',
        color: config('theme.colors.primaryBlue'),
        textDecoration: 'underline'
      }
    }
    addBase(baseStyles)
  }
}
