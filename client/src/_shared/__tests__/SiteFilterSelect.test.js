import React from 'react'
import { render, screen } from 'setupTests'
import SiteFilterSelect from '_shared/SiteFilterSelect'
import { MemoryRouter } from 'react-router-dom'

const doRender = (props, stateOptions) => {
  return render(
    <MemoryRouter>
      <SiteFilterSelect {...props} />
    </MemoryRouter>,
    { initialState: stateOptions }
  )
}

describe('<SiteFilterSelect />', () => {
  it('renders the placeholder text', () => {
    doRender({
      businesses: [
        { id: 1, name: 'business1' },
        { id: 2, name: 'business2' }
      ]
    })
    expect(screen.getByText(/Filter by Site/)).toBeDefined()
  })

  it('renders value from redux state', () => {
    doRender(
      {
        businesses: [
          { id: 1, name: 'business1' },
          { id: 2, name: 'business2' }
        ]
      },
      { ui: { filteredCases: [1] } }
    )
    expect(screen.getByText(/business1/)).toBeDefined()
    expect(screen.queryByText(/business2/)).toBeNull()
  })
})
