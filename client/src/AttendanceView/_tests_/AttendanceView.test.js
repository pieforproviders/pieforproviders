import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import dayjs from 'dayjs'
import { MemoryRouter } from 'react-router-dom'
import { AttendanceView } from '../AttendanceView'

const doRender = stateOptions => {
  return render(
    <MemoryRouter>
      <AttendanceView />
    </MemoryRouter>,
    stateOptions
  )
}

describe('<AttendanceView />', () => {
  beforeEach(() => jest.spyOn(window, 'fetch'))

  afterEach(() => window.fetch.mockRestore())

  it('makes call to /service_days', async () => {
    doRender()
    await waitFor(() => {
      expect(window.fetch).toHaveBeenCalledTimes(1)
      expect(window.fetch.mock.calls[0][0]).toBe(
        '/api/v1/service_days?filter_date=' + dayjs().format('YYYY-MM-DD')
      )
    })
  })

  it('renders content', async () => {
    const { container } = doRender()
    await waitFor(() => {
      expect(container).toHaveTextContent('Screen')
    })
  })

  // TODO: figure out how to test a component that uses ant design breakpoints :(
  // it('renders editable data', async () => {
  //   const { container } = doRender()
  //   window.fetch.mockResolvedValueOnce({
  //     ok: true,
  //     json: async () => [
  //       {
  //         attendances: [
  //           {
  //             absence: null,
  //             check_in: '2022-02-07 06:00:00 -0600',
  //             check_out: '2022-02-07 17:00:00 -0600',
  //             child: {
  //               active: true,
  //               full_name: 'Jasveen Khirwar',
  //               id: '3d56bcbf-4541-4624-bb8c-2165eae748c0',
  //               inactive_reason: null,
  //               last_active_date: null
  //             },
  //             child_approval_id: 'e0c37747-8962-4975-a00d-87af9f138728',
  //             id: '2b4802ab-775b-4a3e-9c87-beefd2bdb438',
  //             time_in_care: '39600',
  //             wonderschool_id: null
  //           }
  //         ],
  //         child_id: '3d56bcbf-4541-4624-bb8c-2165eae748c0',
  //         date: '2022-02-07 01:00:00 -0600',
  //         id: 'e466a37e-2e88-4438-8c85-1b7cf3c39de6',
  //         tags: ['hourly', 'daily'],
  //         total_time_in_care: '39600'
  //       }
  //     ]
  //   })
  //   await waitFor(() => {
  //     // expect(screen.getByText('Jasveen Khirwar')).toBeInTheDocument()
  //     // // expect(screen.findByAltText('editButton')).toBeInTheDocument()
  //     expect(container).toHaveTextContent('Hourly')
  //   })
  // })
})
