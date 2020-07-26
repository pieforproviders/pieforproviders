import React from 'react'
import { render } from '@testing-library/react'
import { CSVImportReview } from '../CSVImportReview'

const doRender = (overrideProps) => {
  const defaultProps = {}
  return render(
    <CSVImportReview {...defaultProps} {...overrideProps} />
  )
}

describe('<CSVImport />', () => {
  const kids = [['Harry', 'Potter', '07-31-1980']]

  it('renders the kids list if data is passed', () => {
    const { container } = doRender({ kids })
    expect(container).toHaveTextContent('Review Imported CSV')
    expect(container).toHaveTextContent('Harry Potter 07-31-1980')
  })

  it('does not render the kids list if data is not passed', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Review Imported CSV')
    expect(container).not.toHaveTextContent('List of kids')
  })
})
