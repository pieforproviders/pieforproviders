import React, { useState } from 'react'
import { FilterFilled } from '@ant-design/icons'
import { Select } from 'antd'
import PropTypes from 'prop-types'
import { useSelector } from 'react-redux'

export default function SiteFilterSelect({ businesses, onChange }) {
  const filteredCases = useSelector(state => state.ui.filteredCases)
  const [filterOpen, setFilterOpen] = useState(false)

  const setWidths = () => {
    const longestName = businesses.reduce(
      (a, b) => (a.name?.length > b.name?.length ? a.name : b.name),
      ''
    )
    return {
      minWidth: `${longestName.length * 20}px`,
      maxWidth: `${longestName.length * 20}px`
    }
  }

  return (
    <>
      <FilterFilled className="absolute z-50 p-2" />
      <Select
        open={filterOpen}
        showSearch={false}
        mode="multiple"
        allowClear
        className="site-filter"
        placeholder="Filter by Site"
        onChange={onChange}
        onSelect={() => setFilterOpen(!filterOpen)}
        dropdownStyle={setWidths()}
        style={{ minWidth: '220px' }}
        role="siteFilter"
        onClick={() => setFilterOpen(!filterOpen)}
        value={filteredCases}
      >
        {businesses.map(business => {
          return (
            <Select.Option key={business?.id} value={business?.id}>
              {business?.name}
            </Select.Option>
          )
        })}
      </Select>
    </>
  )
}

SiteFilterSelect.propTypes = {
  businesses: PropTypes.array,
  onChange: PropTypes.func
}
