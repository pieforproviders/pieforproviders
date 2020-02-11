import React from "react"
import { render } from "@testing-library/react"
import App from "./App"

import { MemoryRouter } from "react-router-dom"
import { shallow } from "enzyme"

describe("<App />", () => {
  const wrapper = shallow(
    <MemoryRouter initialEntries={["/"]} initialIndex={0}>
      <App />
    </MemoryRouter>
  )

  it("renders the App container", () => {
    expect(wrapper.contains(<App />)).toBe(true)
  })

  it("renders dashboard link", () => {
    const { getByText } = render(<App />)
    const content = getByText(/look at the/i)
    expect(content).toBeInTheDocument()
  })
})
