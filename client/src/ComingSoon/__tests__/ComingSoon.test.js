import React from 'react'
import { render, waitFor } from 'setupTests'
import { ComingSoon } from 'ComingSoon/ComingSoon'

describe('ComingSoon', () => {
  it('renders the ComingSoon view', async () => {
    const { container } = render(<ComingSoon />)

    await waitFor(() => {
      expect(container).toHaveTextContent(
        'Pie for Providers is not yet available in your state.'
      )
    })
  })
})
