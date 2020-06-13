// following the 1 shared component == 1 tailwind component plugin pattern

module.exports = function() {
  return function({ addComponents, theme }) {
    const dropdownInput = {
      '.dropdown-input': {
        label: {
          display: 'block'
        },
        select: {
          lineHeight: '1rem',
          borderColor: theme('colors.primaryBlue'),
          borderStyle: 'solid',
          borderRadius: '0',
          borderWidth: '1px',
          height: '2.75rem',
          width: '100%',
          padding: '0.75rem 1rem',
          '&.error-input': {
            borderColor: theme('colors.red1')
          },
          '&.select-box-combo-right, &.select-box-combo-left': {
            backgroundColor: theme('colors.blue3')
          },
          '&.select-box-combo-right': {
            borderWidth: '1px 1px 1px 0'
          },
          '&.select-box-combo-left': {
            borderWidth: '1px 0 1px 1px'
          }
        }
      }
    }

    addComponents(dropdownInput)
  }
}
