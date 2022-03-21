import React from 'react'
import PropTypes from 'prop-types'
import { Radio } from 'antd'
import '_assets/styles/radiobutton-overrides.css'

function SignupQuestion({ onChange, questionText }) {
  return (
    <div className="signup-question mt-1 mb-6 text-left">
      <p className="mb-2 text-gray3 font-normal">{questionText}</p>
      <Radio.Group onChange={onChange}>
        <Radio.Button value="True">True</Radio.Button>
        <Radio.Button value="Mostly True">Mostly True</Radio.Button>
        <Radio.Button value="Mostly False">Mostly False</Radio.Button>
        <Radio.Button value="False">False</Radio.Button>
      </Radio.Group>
    </div>
  )
}

SignupQuestion.propTypes = {
  onChange: PropTypes.func,
  questionText: PropTypes.string
}

export default SignupQuestion
