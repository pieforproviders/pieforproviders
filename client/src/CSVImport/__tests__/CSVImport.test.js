import React from 'react'
import { render } from '@testing-library/react'
import { CSVImport } from '../CSVImport'


const doRender = () => {
  return render(
    <CSVImport />
  )
}

describe('<CSVImport />', () => {
  it('renders the CSVImport page', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Upload Cases')
  })
})
