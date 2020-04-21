import React from 'react'
import { shallow } from 'enzyme'
import { CSVImport } from '../CSVImport'

describe('<CSVImport />', () => {
  const wrapper = shallow(<CSVImport />)

  it('renders the CSVImport container', () => {
    expect(wrapper.find('.csv-import').exists()).toBe(true)
  })
})
