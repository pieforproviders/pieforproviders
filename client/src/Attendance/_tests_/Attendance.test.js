import React from 'react'
import { fireEvent, render, screen, waitFor } from 'setupTests'
import { MemoryRouter } from 'react-router-dom'
import { Attendance } from '../Attendance'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <Attendance />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<Attendance />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('makes call to children when cases is not present', async () => {
    doRender()
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(1)
      expect(window.fetch.mock.calls[0][0]).toBe('/api/v1/children')
    })
  })

  it('renders content', async () => {
    const id = 12
    const { container } = doRender({
      initialState: { businesses: [{ name: 'testing name', id }] }
    })

    await waitFor(() => {
      const select = screen.getAllByRole('siteFilter')[1]
      fireEvent.select(select, { target: { value: id.toString() } })
      expect(select).toHaveProperty('value', id.toString())

      expect(container).toHaveTextContent('Enter attendance history')
      expect(container).toHaveTextContent(
        'Important: if we already have access to your attendance records through another software (for example, Wonderschool) please do not enter your attendance information here. If you have any questions, you can email us at team@pieforproviders.com'
      )
      expect(container).toHaveTextContent('Save')
      expect(container).toHaveTextContent('Filter by Site')
    })
  })
})
