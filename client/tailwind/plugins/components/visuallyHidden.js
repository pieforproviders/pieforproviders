module.exports = function() {
  return function({ addComponents, theme }) {
    const visuallyHidden = {
      '.visually-hidden': {
        position: 'absolute !important',
        height: '1px',
        width: '1px',
        overflow: 'hidden',
        clip: 'rect(1px 1px 1px 1px)' /* IE6, IE7 */,
        clip: 'rect(1px, 1px, 1px, 1px)',
        whiteSpace: 'nowrap' /* added line */
      }
    }

    addComponents(visuallyHidden)
  }
}
