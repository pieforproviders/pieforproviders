import React from 'react'
import PropTypes from 'prop-types'
import { Radio } from 'antd'
import { useTranslation } from 'react-i18next'
import '_assets/styles/radiobutton-overrides.css'

function SignupQuestion({ onChange, questionText, tag }) {
  const { t } = useTranslation()
  return (
    <div className="mt-1 text-left signup-question">
      <p className="mb-2 font-normal text-gray3">{questionText}</p>
      <Radio.Group onChange={onChange} name={`${tag}Question`}>
        <Radio.Button value="True" data-cy={`${tag}-true`}>
          {t('true')}
        </Radio.Button>
        <Radio.Button value="Mostly True" data-cy={`${tag}-mostly-true`}>
          {t('mostlyTrue')}
        </Radio.Button>
        <Radio.Button value="Mostly False" data-cy={`${tag}-mostly-false`}>
          {t('mostlyFalse')}
        </Radio.Button>
        <Radio.Button value="False" data-cy={`${tag}-false`}>
          {t('false')}
        </Radio.Button>
      </Radio.Group>
    </div>
  )
}

SignupQuestion.propTypes = {
  tag: PropTypes.string,
  onChange: PropTypes.func,
  questionText: PropTypes.string
}

export default SignupQuestion
