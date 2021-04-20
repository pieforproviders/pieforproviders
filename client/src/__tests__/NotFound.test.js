import React from 'react'
import { render, screen } from 'setupTests'
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
    doRender()
    expect(screen.getByText(/Oops!/)).toBeDefined()
    expect(screen.getByText(/Go back/)).not.toHaveAttribute('disabled')
  })
})
