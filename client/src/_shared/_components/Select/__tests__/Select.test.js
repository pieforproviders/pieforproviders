import React from 'react'
import { render, screen } from 'setupTests'
import Select from '../Select'
import { Option } from '../Select'

const doRender = () => {
  return render(
    <Select id="test" name="test-name" data-testid="test">
      <Option>Test value</Option>
    </Select>
  )
}

describe('<Select />', () => {
  it('assigns a name attribute to the input select component', async () => {
    doRender()
    const input = screen.getAllByRole('combobox')[0]

    expect(input.getAttribute('name')).toEqual('test-name')
  })
})
