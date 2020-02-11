import React from "react"
import { shallow } from "enzyme"
import { Dashboard } from "./Dashboard"

describe("<Dashboard />", () => {
  const wrapper = shallow(<Dashboard />)

  it("renders the Dashboard container", () => {
    wrapper.update()
    expect(wrapper.find(".users")).to.have.lengthOf(1)
  })
})
