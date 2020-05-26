module.exports = function() {
  return function({ addUtilities }) {
    const required = {
      '.required-label::after': {
        content: '"*"'
      }
    }
    addUtilities(required)
  }
}
