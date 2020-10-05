import React from 'react'
import { render } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import NotFound from '../NotFound'

const doRender = () => {
  return render(
    <MemoryRouter>
      <NotFound />
    </MemoryRouter>
  )
}

describe('<NotFound />', () => {
  it('renders the NotFound page', () => {
    const { container } = doRender()
    expect(container).toHaveTextContent('404: Not found')
  })
})
