import React from 'react'
import { render } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { ErrorBoundaryComponent } from '../ErrorBoundary'

describe('Error Boundary', () => {
  it(`should render error boundary component when there is an error`, () => {
    function Bomb() {
      throw new Error('You dropped the bomb on me.')
    }
    let container
    let topLevelErrors = []
    function handleTopLevelError(event) {
      topLevelErrors.push(event.error)
      event.preventDefault()
    }
    window.addEventListener('error', handleTopLevelError)

    try {
      ;({ container } = render(
        <MemoryRouter>
          <ErrorBoundaryComponent>
            <Bomb />
          </ErrorBoundaryComponent>
        </MemoryRouter>
      ))
    } finally {
      window.removeEventListener('error', handleTopLevelError)
    }
    expect(container).toHaveTextContent('Oops!')
    expect(topLevelErrors.length).toBe(1)
  })
})
