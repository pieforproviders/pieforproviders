import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Select, Radio, Checkbox } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import MaskedInput from 'antd-mask-input'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import '_assets/styles/form-overrides.css'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import i18n from 'i18n'

const { Option } = Select

/**
 * User Signup Page
 */

export function Signup() {
  const [user, setUser] = useState({
    fullName: null,
    greetingName: null,
    email: null,
    language: i18n.language,
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
  const [errors, setErrors] = useState(null)
  let history = useHistory()
  const { t } = useTranslation()

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
      const { errors } = await response.json()
      setErrors(errors[0].detail)
      // TODO: Sentry
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
        <span className="text-red1">* </span>
        {t('agreeToTerms')}
        <a
          href="https://www.pieforproviders.com/terms/"
          target="_blank"
          rel="noopener noreferrer"
        >
          {t('termsOfUse')}
        </a>
      </>
    )
  }

  return (
    <>
      <p className="mb-8">
        <span className="uppercase font-bold">{t('signup')}</span>
        {` ${t('or')} `}
        <Link to="/login" className="uppercase">
          {t('login')}
        </Link>
      </p>

      <Form
        layout="vertical"
        onFinish={onFinish}
        name="signup"
        labelCol={24}
        wrapperCol={{ lg: 12 }}
      >
        <Form.Item
          label={t('organization')}
          name="organization"
          rules={[
            {
              required: true,
              message: t('organizationRequired')
            }
          ]}
        >
          <Input
            placeholder={t('organizationPlaceholder')}
            autoComplete="organization"
            onChange={event =>
              setUser({ ...user, organization: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          label={t('fullName')}
          name="fullName"
          rules={[
            {
              required: true,
              message: t('fullNameRequired')
            }
          ]}
        >
          <Input
            placeholder={t('fullNamePlaceholder')}
            autoComplete="name"
            onChange={event =>
              setUser({ ...user, fullName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          label={t('greetingName')}
          name="greetingName"
          rules={[
            {
              required: true,
              message: t('greetingNameRequired')
            }
          ]}
        >
          <Input
            placeholder={t('greetingNamePlaceholder')}
            autoComplete="nickname"
            onChange={event =>
              setUser({ ...user, greetingName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          name="multiBusiness"
          label={t('multiBusiness')}
          rules={[
            {
              required: true,
              message: t('multiBusinessRequired')
            }
          ]}
        >
          <Select
            style={{ textAlign: 'left' }}
            value={multiBusiness}
            placeholder={t('multiBusinessPlaceholder')}
            onChange={value => {
              setMultiBusiness(value)
            }}
          >
            <Option value="yes">{t('multiBusinessTrue')}</Option>
            <Option value="no">{t('multiBusinessFalse')}</Option>
          </Select>
        </Form.Item>

        <Form.Item name="phone" label={t('phone')}>
          <Input.Group compact>
            <Select
              value={user.phoneType}
              style={{ width: '30%', borderRight: '0', textAlign: 'left' }}
              name="phoneType"
              placeholder={t('phoneTypePlaceholder')}
              onChange={value => {
                setUser({ ...user, phoneType: value })
              }}
            >
              <Option value="cell">{t('phoneTypeCell')}</Option>
              <Option value="home">{t('phoneTypeHome')}</Option>
              <Option value="work">{t('phoneTypeWork')}</Option>
            </Select>

            <Form.Item
              name="phoneNumber"
              style={{ width: '70%', marginBottom: 0 }}
              rules={[
                {
                  pattern: /^\d{3}-\d{3}-\d{4}$/,
                  message: t('phoneNumberInvalid')
                }
                // TODO: these rules aren't working
              ]}
            >
              <MaskedInput
                mask="111-111-1111"
                placeholder="___-___-____"
                size="10"
                className="h-8"
                onChange={event =>
                  setUser({ ...user, phoneNumber: event.target.value })
                }
              />
            </Form.Item>
          </Input.Group>
        </Form.Item>

        <Form.Item
          label={t('preferredLanguage')}
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
              { required: true, message: t('preferredLanguageRequired') }
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
              {t('english')}
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
              {t('spanish')}
            </Radio.Button>
          </Radio.Group>
        </Form.Item>

        <Form.Item
          label={t('email')}
          name="email"
          rules={[
            {
              type: 'email',
              message: t('emailInvalid')
            },
            {
              required: true,
              message: t('emailRequired')
            }
          ]}
          hasFeedback={!!errors?.email}
          validateStatus={errors?.email && 'error'}
          help={errors?.email && `Email ${errors.email.join(', ')}`}
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
          label={t('password')}
          rules={[
            {
              required: true,
              message: t('passwordRequired')
            },
            {
              pattern: /^(?=.*\d)(?=.*[a-zA-Z]).{8,}$/,
              message: t('passwordInvalid')
            }
          ]}
          hasFeedback
        >
          <Input.Password
            placeholder={t('passwordPlaceholder')}
            autoComplete="new-password"
            onChange={event =>
              setUser({ ...user, password: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          name="passwordConfirmation"
          label={t('passwordConfirmation')}
          dependencies={['password']}
          hasFeedback
          rules={[
            { required: true, message: t('passwordConfirmationRequired') },
            ({ getFieldValue }) => ({
              validator(rule, value) {
                if (!value || getFieldValue('password') === value) {
                  return Promise.resolve()
                }
                return Promise.reject(t('passwordConfirmationMatch'))
              }
            })
          ]}
        >
          <Input.Password
            placeholder={t('passwordConfirmationPlaceholder')}
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
              message: t('termsRequired')
            }
          ]}
          wrapperCol={{ lg: 24 }}
        >
          <Checkbox
            style={{ textAlign: 'left' }}
            checked={user.serviceAgreementAccepted}
            className="flex"
            name="serviceAgreementAccepted"
            onChange={() => {
              setUser({
                ...user,
                serviceAgreementAccepted: !user.serviceAgreementAccepted
              })
            }}
          >
            <TermsLabel />
          </Checkbox>
        </Form.Item>
        <Form.Item wrapperCol={{ lg: 8 }} className="text-center">
          <PaddedButton text={t('signup')} />
        </Form.Item>
      </Form>
    </>
  )
}
