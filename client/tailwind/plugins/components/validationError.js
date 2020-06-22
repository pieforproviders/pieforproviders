// following the 1 shared component == 1 tailwind component plugin pattern

module.exports = function() {
  return function({ addComponents, theme }) {
    const errorInput = {
      '.error-input': {
        '& + div': {
          lineHeight: '1rem'
        },
        '& + div > svg': {
          fontSize: '1rem',
          verticalAlign: 'bottom'
        }
      }
    }

    addComponents(errorInput)
  }
}
