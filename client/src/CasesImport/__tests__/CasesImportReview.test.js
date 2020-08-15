import React from 'react'
import { render } from '@testing-library/react'
import { CasesImportReview } from '../CasesImportReview'

const doRender = overrideProps => {
  const defaultProps = {}
  return render(<CasesImportReview {...defaultProps} {...overrideProps} />)
}

describe('<CasesImportReview />', () => {
  const kids = [
    {
      firstName: 'Harry',
      lastName: 'Potter',
      dateOfBirth: '1980-07-31',
      key: 'harry'
    }
  ]

  it('renders the kids list if data is passed', () => {
    const { container } = doRender({ kids })
    expect(container).toHaveTextContent('Review Imported Cases')
    expect(container).toHaveTextContent('Harry')
    expect(container).toHaveTextContent('Potter')
    expect(container).toHaveTextContent('1980-07-31')
  })

  it('does not render the kids list if data is not passed', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Review Imported Cases')
    expect(container).not.toHaveTextContent('List of kids')
  })
})
