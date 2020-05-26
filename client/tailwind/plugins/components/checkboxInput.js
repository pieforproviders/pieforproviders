module.exports = function() {
  return function({ addComponents, theme }) {
    const checkboxInput = {
      '.checkbox-input': {
        label: {
          color: theme('colors.gray1'),
          display: 'inline-block',
          position: 'relative',
          paddingLeft: '22px',
          // hacks to make a styled checkbox
          '&::before, &::after': {
            position: 'absolute'
          },
          '&::before': {
            content: '""',
            display: 'inline-block',
            height: '16px',
            width: '16px',
            border: '2px solid',
            borderRadius: '3px',
            borderColor: theme('colors.primaryBlue'),
            top: '3px',
            left: '0px'
          },
          '&::after': {
            // build a checkbox out of the box element rotated w/
            // borders on only 2 sides 😍
            content: '""',
            display: 'inline-block',
            height: '6px',
            width: '9px',
            borderLeft: '2px solid',
            borderBottom: '2px solid',
            borderColor: theme('colors.white'),
            transform: 'rotate(-45deg)',
            left: '4px',
            top: '7px'
          }
        },
        input: {
          // leave the checkbox here at 0 opacity so screen readers will still
          // pick it up
          opacity: '0',
          position: 'absolute',
          '& + label::after': {
            content: 'none'
          },
          '&:checked + label::after': {
            content: '""'
          },
          '&:checked + label::before': {
            content: '""',
            backgroundColor: theme('colors.primaryBlue')
          },
          '&:focus + label::before': {
            outline: '0',
            boxShadow: `0 0 4px 0 ${theme('colors.primaryBlue')}`
          }
        }
      }
    }

    addComponents(checkboxInput)
  }
}
