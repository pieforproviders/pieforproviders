import React from "react"
import { shallow } from "enzyme"
import { Login } from "./Login"

describe("<Login />", () => {
  const wrapper = shallow(<Login />)

  it("renders the Login container", () => {
    wrapper.update()
    expect(wrapper.find(".login")).to.have.lengthOf(1)
  })
})
