import React, { useEffect, useState } from 'react'
import { Alert, Form, Input, Select, Radio, Checkbox } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import { Link } from 'react-router-dom'
import MaskedInput from 'antd-mask-input'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useMultiBusiness } from '_shared/_hooks/useMultiBusiness'
import '_assets/styles/form-overrides.css'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import i18n from 'i18n'
import ConfirmationSent from './ConfirmationSent'

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
  const [success, setSuccess] = useState(false)
  const [validationErrors, setValidationErrors] = useState(null)
  const [error, setError] = useState(false)
  const { makeRequest } = useApiResponse()
  const { setIsMultiBusiness } = useMultiBusiness()
  const { t } = useTranslation()

  const onFinish = async () => {
    setValidationErrors(null)
    setError(false)

    setIsMultiBusiness(multiBusiness)
    const response = await makeRequest({
      type: 'post',
      url: '/signup',
      data: { user: user }
    })
    if (response.status === 201) {
      setSuccess(true)
    } else if (response.status === 422) {
      const { errors } = await response.json()
      setValidationErrors(errors)
    } else {
      setError(true)
    }
  }

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

  if (success) {
    return <ConfirmationSent userEmail={user.email} />
  }

  return (
    <main>
      <div className="mb-8">
        <h1 className="uppercase font-bold inline-block">{t('signup')}</h1>
        {` ${t('or')} `}
        <Link to="/login" className="uppercase">
          {t('login')}
        </Link>
      </div>

      {error && (
        <Alert
          className="mb-2"
          message={t('genericErrorMessage')}
          type="error"
        />
      )}

      <Form
        layout="vertical"
        onFinish={onFinish}
        name="signup"
        wrapperCol={{ md: 12 }}
      >
        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            data-cy="organization"
            value={user.organization}
            onChange={event =>
              setUser({ ...user, organization: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            value={user.fullName}
            data-cy="name"
            onChange={event =>
              setUser({ ...user, fullName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            data-cy="greetingName"
            value={user.greetingName}
            onChange={event =>
              setUser({ ...user, greetingName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            data-cy="multiBusiness"
            onChange={value => {
              setMultiBusiness(value)
            }}
          >
            <Option value="yes" data-cy="yesMultiBusiness">
              {t('multiBusinessTrue')}
            </Option>
            <Option value="no" data-cy="noSingleBusiness">
              {t('multiBusinessFalse')}
            </Option>
          </Select>
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
          name="phone"
          label={`${t('phone')} (${t('phoneNote')})`}
        >
          <Input.Group compact>
            <label htmlFor="rc_select_1" className="sr-only">
              {t('phoneType')}
            </label>
            <Select
              value={user.phoneType}
              style={{ width: '30%', borderRight: '0', textAlign: 'left' }}
              name="phoneType"
              data-cy="phoneType"
              placeholder={t('phoneTypePlaceholder')}
              onChange={value => {
                setUser({ ...user, phoneType: value })
              }}
            >
              <Option value="cell" data-cy="cellPhone">
                {t('phoneTypeCell')}
              </Option>
              <Option value="home" data-cy="homePhone">
                {t('phoneTypeHome')}
              </Option>
              <Option value="work" data-cy="workPhone">
                {t('phoneTypeWork')}
              </Option>
            </Select>

            <label htmlFor="signup_phoneNumber" className="sr-only">
              {t('phone')}
            </label>
            <Form.Item
              className="body-2-bold text-primaryBlue"
              name="phoneNumber"
              style={{ width: '70%', marginBottom: 0 }}
              rules={[
                {
                  pattern: /^\d{3}-\d{3}-\d{4}$/,
                  message: t('phoneNumberInvalid')
                }
              ]}
              hasFeedback={!!validationErrors?.phone_number}
              validateStatus={validationErrors?.phone_number && 'error'}
              help={
                validationErrors?.phone_number &&
                `${t('phone')} ${t(validationErrors.phone_number[0].error)}`
              }
            >
              <MaskedInput
                mask="111-111-1111"
                placeholder="___-___-____"
                size="10"
                className="h-8"
                data-cy="phoneNumber"
                value={user.phoneNumber}
                onChange={event =>
                  setUser({ ...user, phoneNumber: event.target.value })
                }
              />
            </Form.Item>
          </Input.Group>
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue mb-0 text-center"
          label={t('preferredLanguage')}
          name="language"
          valuePropName="checked"
          // explicity styling around Ant's strong "width of radio buttons" opinion
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
            <Radio.Button value="en" data-cy="languageEn" className="w-1/2">
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
            <Radio.Button value="es" data-cy="languageEs" className="w-1/2">
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
          className="body-2-bold text-primaryBlue"
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
          hasFeedback={!!validationErrors?.email}
          validateStatus={validationErrors?.email && 'error'}
          help={
            validationErrors?.email &&
            `${t('email')} ${t(validationErrors.email[0].error)}`
          }
          onChange={() => {
            if (validationErrors?.email) {
              setValidationErrors({ email: null })
            }
          }}
        >
          <Input
            placeholder="amanda@gmail.com"
            autoComplete="email"
            type="email"
            data-cy="email"
            onChange={event => setUser({ ...user, email: event.target.value })}
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            data-cy="password"
            onChange={event =>
              setUser({ ...user, password: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
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
            data-cy="passwordConfirmation"
            onChange={event =>
              setUser({ ...user, passwordConfirmation: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue"
          name="terms"
          valuePropName="checked"
          rules={[
            {
              validator: (_, value) =>
                value ? Promise.resolve() : Promise.reject(t('termsRequired'))
            }
          ]}
          wrapperCol={{ md: 24 }}
        >
          <Checkbox
            style={{ textAlign: 'left' }}
            checked={user.serviceAgreementAccepted}
            className="flex"
            data-cy="terms"
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
        <Form.Item wrapperCol={{ md: 8 }} className="text-center">
          <PaddedButton data-cy="signupBtn" text={t('signup')} />
        </Form.Item>
      </Form>
    </main>
  )
}
