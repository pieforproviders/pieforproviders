import React from 'react'
// import { MemoryRouter } from 'react-router-dom'
import { render } from 'setupTests'
import SignupQuestion from '../SignupQuestion'

describe('<SignupQuestion />', () => {
  it('renders the signup page', () => {
    const { container } = render(
      <SignupQuestion onChange={() => {}} questionText={'A question?'} />
    )
    expect(container).toHaveTextContent('A question?')
    expect(container).toHaveTextContent('True')
    expect(container).toHaveTextContent('Mostly True')
    expect(container).toHaveTextContent('Mostly False')
    expect(container).toHaveTextContent('False')
  })
})
