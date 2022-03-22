import React from 'react'
import PropTypes from 'prop-types'
import { Radio } from 'antd'
import { useTranslation } from 'react-i18next'
import '_assets/styles/radiobutton-overrides.css'

function SignupQuestion({ onChange, questionText }) {
  const { t } = useTranslation()
  return (
    <div className="signup-question mt-1 text-left">
      <p className="mb-2 text-gray3 font-normal">{questionText}</p>
      <Radio.Group onChange={onChange}>
        <Radio.Button value="True">{t('true')}</Radio.Button>
        <Radio.Button value="Mostly True">{t('mostyleTrue')}</Radio.Button>
        <Radio.Button value="Mostly False">{t('mostlyFalse')}</Radio.Button>
        <Radio.Button value="False">{t('false')}</Radio.Button>
      </Radio.Group>
    </div>
  )
}

SignupQuestion.propTypes = {
  onChange: PropTypes.func,
  questionText: PropTypes.string
}

export default SignupQuestion
