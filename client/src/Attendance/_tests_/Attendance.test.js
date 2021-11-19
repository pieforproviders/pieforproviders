import React from 'react'
import { render, waitFor } from 'setupTests'
import { Attendance } from '../Attendance'

const doRender = stateOptions => {
  return render(<Attendance />, stateOptions)
}

describe('<Attendance />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('makes call to case_list_for_dashboard when cases is not present', async () => {
    doRender()
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(1)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/case_list_for_dashboard'
      )
    })
  })

  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Enter attendance history')
      expect(container).toHaveTextContent(
        'Important: if we already have access to your attendance records through another software (for example, Wonderschool) please do not enter your attendance information here. If you have any questions, you can email us at team@pieforproviders.com'
      )
      expect(container).toHaveTextContent('Save')
    })
  })
})
