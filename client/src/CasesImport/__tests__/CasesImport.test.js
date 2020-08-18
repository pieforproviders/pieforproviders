import React from 'react'
import { render } from '@testing-library/react'
import { CasesImport } from '../CasesImport'

const doRender = () => {
  return render(<CasesImport />)
}

describe('<CasesImport />', () => {
  it('renders the CasesImport page', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('Upload Cases')
  })
})
