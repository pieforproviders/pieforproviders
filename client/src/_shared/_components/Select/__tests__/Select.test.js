import React from 'react'
import { render, screen, waitFor } from 'setupTests'
import Select from '../Select'
import { Option } from '../Select'
import userEvent from '@testing-library/user-event'

const doRender = () => {
  return render(
    <Select id="test" name="test-name" data-testid="test" onChange={() => ''}>
      <Option value="1">Test value</Option>
      <Option value="2">Test value 2</Option>
    </Select>
  )
}

describe('<Select />', () => {
  it('creates a hidden input with attributes', async () => {
    const { container } = doRender()
    const hiddenInput = container.querySelector('#test')
    const selectInput = screen.getAllByRole('combobox')[0]

    expect(hiddenInput.getAttribute('name')).toEqual('test-name')
    expect(hiddenInput.getAttribute('id')).toEqual('test')
    expect(hiddenInput.getAttribute('type')).toEqual('hidden')
    expect(selectInput.getAttribute('name')).toBeNull()
    expect(selectInput.getAttribute('id')).toEqual('antd-test')
  })

  it('changes the value on the hidden input based on the value selected on the dropdown', async () => {
    const { container } = doRender()
    const selectInput = screen.getAllByRole('combobox')[0]

    // Opening dropdown
    await waitFor(() => {
      userEvent.click(selectInput)
    })

    const option = document.getElementsByClassName(
      'ant-select-item-option-content'
    )[0]
    expect(option).toHaveTextContent('Test value')

    // Selecting option from dropdown
    await waitFor(() =>
      userEvent.click(option, undefined, { skipPointerEventsCheck: true })
    )
    const hiddenInput = container.querySelector('#test')
    expect(hiddenInput).toHaveProperty('value', '1')
  })
})
