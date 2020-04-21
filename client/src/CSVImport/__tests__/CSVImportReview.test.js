import React from 'react'
import { shallow } from 'enzyme'
import { CSVImportReview } from '../CSVImportReview'

describe('<CSVImport />', () => {
  const kids = [['Harry', 'Potter', '07-31-1980']]
  let wrapper

  it('renders the kids list if data is passed', () => {
    wrapper = shallow(<CSVImportReview kids={kids} />)
    expect(wrapper.find('.csv-import-review').exists()).toBe(true)
    expect(wrapper.find('.kids-list').exists()).toBe(true)
    expect(wrapper.find('.kids-list').text()).toMatch(/Potter/)
  })

  it('does not render the kids list if data is not passed', () => {
    wrapper = shallow(<CSVImportReview kids={null} />)
    expect(wrapper.find('.csv-import-review').exists()).toBe(true)
    expect(wrapper.find('.kids-list').exists()).toBe(false)
  })
})
