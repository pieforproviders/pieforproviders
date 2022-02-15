import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import { EditAttendanceModal } from '../EditAttendanceModal'

const doRender = (props, options) =>
  render(<EditAttendanceModal {...props} />, options)

describe('EditAttendanceModal', () => {
  it('renders content', async () => {
    doRender({
      editAttendanceModalData: {},
      titleData: { childName: 'Candice' }
    })

    await waitFor(() => {
      expect(screen.getByText('Add check-in time')).toBeInTheDocument()
      expect(screen.getByText('CHECK OUT')).toBeInTheDocument()
      expect(screen.getByText('CHECK IN')).toBeInTheDocument()
      expect(screen.getByText('Candice -')).toBeInTheDocument()
    })
  })
})
