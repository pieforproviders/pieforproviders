import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Button, Select, Radio, Checkbox } from 'antd'
import MaskedInput from 'antd-mask-input'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import '_assets/styles/form-overrides.css'
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
    if (response.status === 201) {
      history.push('/confirmation')
    } else {
      // TODO: Sentry
      // TODO: Display error to user
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
    // The span with the asterisk is to match Ant Design's built-in required styling
    return (
      <>
        <span className="text-red1">* </span>I have read and agree to the{' '}
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
            autoComplete="organization"
            onChange={event =>
              setUser({ ...user, organization: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
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
            autoComplete="name"
            onChange={event =>
              setUser({ ...user, fullName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
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
            placeholder="Amanda"
            autoComplete="nickname"
            onChange={event =>
              setUser({ ...user, greetingName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          name="multiBusiness"
          label="Are you managing subsidy cases for multiple child care businesses?"
          rules={[
            {
              required: true,
              message: 'Select your business type'
            }
          ]}
        >
          <Select
            style={{ textAlign: 'left' }}
            value={multiBusiness}
            placeholder="Choose one"
            onChange={value => {
              setMultiBusiness(value)
            }}
          >
            <Option value="yes">
              Yes, managing multiple child care businesses
            </Option>
            <Option value="no">
              No, I am managing 1 child care business only
            </Option>
          </Select>
        </Form.Item>

        <Form.Item
          name="phone"
          label="Phone number (we will only call or text if you want us to.)"
        >
          <Input.Group compact>
            <Select
              value={user.phoneType}
              style={{ width: '30%', borderRight: '0', textAlign: 'left' }}
              name="phoneType"
              placeholder="Choose one"
              onChange={value => {
                setUser({ ...user, phoneType: value })
              }}
            >
              <Option value="cell">Cell</Option>
              <Option value="home">Home</Option>
              <Option value="work">Work</Option>
            </Select>

            <Form.Item
              style={{ width: '70%', marginBottom: 0 }}
              rules={[
                { pattern: /^\d{10}$/, message: 'Phone number is invalid' }
                // TODO: these rules aren't working
              ]}
            >
              <Input
                name="phoneNumber"
                onChange={event =>
                  setUser({ ...user, phoneNumber: event.target.value })
                }
              />
            </Form.Item>
          </Input.Group>
        </Form.Item>

        <Form.Item
          label="Preferred Language"
          name="language"
          valuePropName="checked"
          // explicity styling around Ant's strong "width of radio buttons" opinion
          className="mb-0 text-center"
          style={{ marginBottom: '-6px' }}
        >
          <Radio.Group
            value={user.language}
            optionType="button"
            buttonStyle="solid"
            className="w-full"
            onChange={event =>
              setUser({ ...user, language: event.target.value })
            }
            rules={[
              { required: true, message: 'Preferred language is required' }
            ]}
          >
            <Radio.Button value="en" className="w-1/2">
              {user.language === 'en' ? (
                <CheckCircleIcon
                  style={{
                    width: '0.875rem',
                    height: '0.875rem',
                    marginRight: '0.5rem',
                    verticalAlign: 'text-bottom'
                  }}
                />
              ) : (
                <RadioButtonUncheckedIcon
                  style={{
                    width: '0.875rem',
                    height: '0.875rem',
                    marginRight: '0.5rem',
                    verticalAlign: 'text-bottom'
                  }}
                />
              )}
              English
            </Radio.Button>
            <Radio.Button value="es" className="w-1/2">
              {user.language === 'es' ? (
                <CheckCircleIcon
                  style={{
                    width: '0.875rem',
                    height: '0.875rem',
                    marginRight: '0.5rem',
                    verticalAlign: 'text-bottom'
                  }}
                />
              ) : (
                <RadioButtonUncheckedIcon
                  style={{
                    width: '0.875rem',
                    height: '0.875rem',
                    marginRight: '0.5rem',
                    verticalAlign: 'text-bottom'
                  }}
                />
              )}
              Español
            </Radio.Button>
          </Radio.Group>
        </Form.Item>

        <Form.Item
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
            autoComplete="email"
            type="email"
            onChange={event => setUser({ ...user, email: event.target.value })}
          />
        </Form.Item>

        <Form.Item
          name="password"
          label="Password"
          rules={[
            {
              required: true,
              message: 'Password is required.'
            },
            {
              pattern: /^(?=.*\d)(?=.*[a-zA-Z]).{8,}$/,
              message:
                'Password must be a minimum of 8 characters, and include numbers and letters.'
            }
          ]}
          hasFeedback
        >
          <Input.Password
            placeholder="8+ characters, letters and numbers"
            autoComplete="new-password"
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
            { required: true, message: 'Password confirmation is required' },
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
            placeholder="Confirm your password"
            autoComplete="new-password"
            onChange={event =>
              setUser({ ...user, passwordConfirmation: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          name="terms"
          valuePropName="checked"
          rules={[
            {
              required: true,
              message: 'Please read and agree to our Terms of Service'
            }
          ]}
        >
          <Checkbox
            style={{ textAlign: 'left' }}
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
          >
            <TermsLabel />
          </Checkbox>
        </Form.Item>
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
