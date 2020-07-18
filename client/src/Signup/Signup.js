import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Button, Alert, Select, Radio, Checkbox } from 'antd'
import MaskedInput from 'antd-mask-input'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import '_assets/styles/layouts.css'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'

const { Option } = Select

/**
 * User Signup Page
 */

export function Signup() {
  const [user, setUser] = useState({
    fullName: null,
    greetingName: null,
    email: null,
    language: 'en',
    organization: null,
    password: null,
    passwordConfirmation: null,
    phoneType: 'cell',
    phoneNumber: null,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    serviceAgreementAccepted: false
  })
  const [multiBusiness, setMultiBusiness] = useState(null)
  const { makeRequest } = useApiResponse()
  let history = useHistory()

  const onFinish = async () => {
    localStorage.setItem('pieMultiBusiness', multiBusiness)
    const response = await makeRequest({
      type: 'post',
      url: '/signup',
      data: { user: user }
    })
    if (Object.keys(response).length > 0) {
      history.push('/confirmation')
    } else {
      // TODO: Sentry
      console.log('error creating')
    }
  }

  // Google Analytics
  useEffect(() => {
    if (process.env.NODE_ENV === 'production') {
      ReactGA.pageview(window.location.pathname + window.location.search)
      ReactGA.event({
        category: 'Guest',
        action: 'Landed on Signup Page'
      })
    }
  }, [])

  // Label for the Terms and Conditions checkbox with a link embedded
  const TermsLabel = () => {
    return (
      <>
        I have read and agree to the{' '}
        <a
          href="https://www.pieforproviders.com/terms/"
          target="_blank"
          rel="noopener noreferrer"
        >
          Pie for Providers Terms of Use
        </a>
      </>
    )
  }

  return (
    <>
      <p className="mb-4">
        <span className="uppercase font-bold">Sign Up</span> or{' '}
        <Link to="/login" className="uppercase">
          Log in
        </Link>
      </p>

      <Form layout="vertical" onFinish={onFinish}>
        <Form.Item
          className="text-primaryBlue"
          label="Name of Organization"
          name="organization"
          rules={[
            {
              required: true,
              message: 'Name of organization is required'
            }
          ]}
        >
          <Input
            placeholder="Amanda's Daycare"
            onChange={event =>
              setUser({ ...user, organization: event.target.value })
            }
          />
        </Form.Item>
        <Form.Item
          className="text-primaryBlue"
          label="Email"
          name="email"
          rules={[
            {
              type: 'email',
              required: true,
              message: 'Email address is required'
            }
          ]}
        >
          <Input
            placeholder="amanda@gmail.com"
            type="email"
            onChange={event => setUser({ ...user, email: event.target.value })}
          />
        </Form.Item>

        <Form.Item
          className="text-primaryBlue"
          label="Full name"
          name="fullName"
          rules={[
            {
              required: true,
              message: 'Full name is required'
            }
          ]}
        >
          <Input
            placeholder="Amanda Diaz"
            onChange={event =>
              setUser({ ...user, fullName: event.target.value })
            }
          />
        </Form.Item>
        <Form.Item
          className="text-primaryBlue"
          label="What should we call you?"
          name="greetingName"
          rules={[
            {
              required: true,
              message: 'Greeting name is required'
            }
          ]}
        >
          <Input
            placeholder="Amanda Diaz"
            onChange={event =>
              setUser({ ...user, greetingName: event.target.value })
            }
          />
        </Form.Item>
        <Form.Item label="Are you managing subsidy cases for multiple child care businesses?">
          <Select
            defaultValue={multiBusiness}
            placeholder="Choose one"
            onChange={value => {
              setMultiBusiness(value)
            }}
            rules={[
              {
                required: true,
                message: 'Single or multi-business option is required'
              }
            ]}
          >
            <Option value="yes">
              Yes, managing multiple child care businesses
            </Option>
            <Option value="no">
              No, I am managing 1 child care business only
            </Option>
          </Select>
        </Form.Item>

        <Form.Item label="Phone number (we will only call or text if you want us to.)">
          <Input.Group compact>
            <Select
              style={{ width: '30%' }}
              name="phoneType"
              placeholder="Choose one"
              onChange={value => {
                setUser({ ...user, phoneType: value })
              }}
              rules={[
                {
                  required: true,
                  message: 'Select a phone type'
                }
              ]}
            >
              <Option value="cell">Cell</Option>
              <Option value="home">Home</Option>
              <Option value="work">Work</Option>
            </Select>

            <Form.Item style={{ width: '70%', marginBottom: 0 }}>
              <MaskedInput
                mask="111-111-1111"
                name="phoneNumber"
                size="10"
                onChange={event =>
                  setUser({ ...user, phoneNumber: event.target.value })
                }
              />
            </Form.Item>
          </Input.Group>
        </Form.Item>

        <Form.Item label="Preferred Language">
          <Radio.Group
            value={user.language}
            optionType="button"
            buttonStyle="solid"
            onChange={event =>
              setUser({ ...user, language: event.target.value })
            }
          >
            <Radio.Button value="en">
              {user.language === 'en' ? (
                <CheckCircleIcon />
              ) : (
                <RadioButtonUncheckedIcon />
              )}
              English
            </Radio.Button>
            <Radio.Button value="es">
              {user.language === 'es' ? (
                <CheckCircleIcon />
              ) : (
                <RadioButtonUncheckedIcon />
              )}
              Español
            </Radio.Button>
          </Radio.Group>
        </Form.Item>

        <Form.Item
          name="password"
          label="Password"
          rules={[
            () => ({
              validator(rule, value) {
                if (value.match(/^(?=.*\d)(?=.*[a-zA-Z]).{8,}$/)) {
                  return Promise.resolve()
                }
                return Promise.reject(
                  'Password must be a minimum of 8 characters, and include numbers and letters.'
                )
              }
            })
          ]}
          hasFeedback
        >
          <Input.Password
            onChange={event =>
              setUser({ ...user, password: event.target.value })
            }
          />
        </Form.Item>
        <Form.Item
          name="passwordConfirmation"
          label="Confirm Password"
          dependencies={['password']}
          hasFeedback
          rules={[
            ({ getFieldValue }) => ({
              validator(rule, value) {
                if (!value || getFieldValue('password') === value) {
                  return Promise.resolve()
                }
                return Promise.reject(
                  'The two passwords that you entered do not match!'
                )
              }
            })
          ]}
        >
          <Input.Password
            onChange={event =>
              setUser({ ...user, passwordConfirmation: event.target.value })
            }
          />
        </Form.Item>
        <Checkbox
          checked={user.serviceAgreementAccepted}
          name="serviceAgreementAccepted"
          onChange={() => {
            // TODO: adds a validation trigger on change so the user doesn't have to
            // click away from the checkbox before clicking the submit button
            setUser({
              ...user,
              serviceAgreementAccepted: !user.serviceAgreementAccepted
            })
          }}
          rules={[
            {
              required: true,
              message: 'Please read and agree to our Terms of Service'
            }
          ]}
        >
          <TermsLabel />
        </Checkbox>
        <Form.Item>
          <Button
            type="primary"
            htmlType="submit"
            className="mt-2 font-semibold uppercase"
          >
            Sign Up
          </Button>
        </Form.Item>
      </Form>
    </>
  )
}
