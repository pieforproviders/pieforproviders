import React from 'react'
import PropTypes from 'prop-types'
import { Select } from 'antd'
import { useTranslation } from 'react-i18next'

const { Option } = Select

function StateDropdown({ onChange }) {
  const { t } = useTranslation()
  const stateOptions = [
    { value: 'AL', displayName: 'Alabama' },
    { value: 'AK', displayName: 'Alaska' },
    { value: 'AZ', displayName: 'Arizona' },
    { value: 'AR', displayName: 'Arkansas' },
    { value: 'CA', displayName: 'California' },
    { value: 'CO', displayName: 'Colorado' },
    { value: 'CT', displayName: 'Connecticut' },
    { value: 'DE', displayName: 'Delaware' },
    { value: 'DC', displayName: 'District of Columbia' },
    { value: 'FL', displayName: 'Florida' },
    { value: 'GA', displayName: 'Georgia' },
    { value: 'HI', displayName: 'Hawaii' },
    { value: 'ID', displayName: 'Idaho' },
    { value: 'IL', displayName: 'Illinois' },
    { value: 'IN', displayName: 'Indiana' },
    { value: 'IA', displayName: 'Iowa' },
    { value: 'KS', displayName: 'Kansas' },
    { value: 'KY', displayName: 'Kentucky' },
    { value: 'LA', displayName: 'Louisiana' },
    { value: 'ME', displayName: 'Maine' },
    { value: 'MD', displayName: 'Maryland' },
    { value: 'MA', displayName: 'Massachusetts' },
    { value: 'MI', displayName: 'Michigan' },
    { value: 'MN', displayName: 'Minnesota' },
    { value: 'MS', displayName: 'Mississippi' },
    { value: 'MO', displayName: 'Missouri' },
    { value: 'MT', displayName: 'Montana' },
    { value: 'NE', displayName: 'Nebraska' },
    { value: 'NV', displayName: 'Nevada' },
    { value: 'NH', displayName: 'New Hampshire' },
    { value: 'NJ', displayName: 'New Jersey' },
    { value: 'NM', displayName: 'New Mexico' },
    { value: 'NY', displayName: 'New York' },
    { value: 'NC', displayName: 'North Carolina' },
    { value: 'ND', displayName: 'North Dakota' },
    { value: 'OH', displayName: 'Ohio' },
    { value: 'OK', displayName: 'Oklahoma' },
    { value: 'OR', displayName: 'Oregon' },
    { value: 'PA', displayName: 'Pennsylvania' },
    { value: 'RI', displayName: 'Rhode Island' },
    { value: 'SC', displayName: 'South Carolina' },
    { value: 'SD', displayName: 'South Dakota' },
    { value: 'TN', displayName: 'Tennessee' },
    { value: 'TX', displayName: 'Texas' },
    { value: 'UT', displayName: 'Utah' },
    { value: 'VT', displayName: 'Vermont' },
    { value: 'VA', displayName: 'Virginia' },
    { value: 'WA', displayName: 'Washington' },
    { value: 'WV', displayName: 'West Virginia' },
    { value: 'WI', displayName: 'Wisconsin' },
    { value: 'WY', displayName: 'Wyoming' }
  ]
  return (
    <Select
      className="text-left"
      placeholder={t('chooseOne')}
      onChange={onChange}
      data-cy="state"
    >
      {stateOptions.map(state => (
        <Option key={state.value} value={state.value} data-cy={state.value}>
          {state.displayName}
        </Option>
      ))}
    </Select>
  )
}

StateDropdown.propTypes = {
  onChange: PropTypes.func
}

export default StateDropdown
