import React, { useState } from 'react'
import { Alert, Form, Input, Select, Radio, Checkbox } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import { Link } from 'react-router-dom'
import MaskedInput from 'antd-mask-input'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import '_assets/styles/form-overrides.css'
import '_assets/styles/next-button-overrides.css'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import i18n from 'i18n'
import ConfirmationSent from './ConfirmationSent'
import StateDropdown from './StateDropdown'
import SignupQuestion from './SignupQuestion'

const { Option } = Select
const { TextArea } = Input

/**
 * User Signup Page
 */

export function Signup() {
  const [user, setUser] = useState({
    fullName: null,
    email: null,
    language: i18n.language,
    password: null,
    phoneType: 'cell',
    phoneNumber: null,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    state: null,
    serviceAgreementAccepted: false,
    stressedAboutBilling: null,
    acceptMoreSubsidyFamilies: null,
    notAsMuchMoney: null,
    tooMuchTime: null,
    getFromPie: null
  })
  const [success, setSuccess] = useState(false)
  const [validationErrors, setValidationErrors] = useState(null)
  const [error, setError] = useState(false)
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()

  const onFinish = async () => {
    setValidationErrors(null)
    setError(false)

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
          style={{ color: '#1b82ab' }}
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
    <main className="text-center">
      <div className="mb-8">
        <h1 className="h1-large">{t('gettingStartedWelcome')}</h1>
        <h2 className="eyebrow-small mb-5">{t('signupNote')}</h2>
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
        className="m-20 signup"
      >
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
          name="state"
          label={t('state')}
          rules={[
            {
              required: true,
              message: 'Please choose a state'
            }
          ]}
        >
          <StateDropdown
            onChange={value => setUser({ ...user, state: value })}
          />
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
          className="body-2-bold text-primaryBlue questions pb-5"
          label={t('helpUsUnderstand')}
        >
          <Form.Item name="feelStressedQuestion">
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, stressedAboutBilling: event.target.value })
              }
              questionText={t('feelStressed')}
            />
          </Form.Item>
          <Form.Item name="moneyQuestion">
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, notAsMuchMoney: event.target.value })
              }
              questionText={t('money')}
            />
          </Form.Item>
          <Form.Item name="timeQuestion">
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, tooMuchTime: event.target.value })
              }
              questionText={t('time')}
            />
          </Form.Item>
          <Form.Item name="acceptingMoreQuestion">
            <SignupQuestion
              onChange={event =>
                setUser({
                  ...user,
                  acceptMoreSubsidyFamilies: event.target.value
                })
              }
              questionText={t('acceptingMoreFamilies')}
            />
          </Form.Item>
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue questions"
          name="openSignUpQuestion"
          label={t('hopeForP4P')}
        >
          <TextArea
            rows={3}
            onChange={event =>
              setUser({ ...user, getFromPie: event.target.value })
            }
            className="open-signup-question"
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
        <Form.Item className="text-center">
          <PaddedButton
            data-cy="signupBtn"
            text={t('next')}
            classes="bg-green1 w-full next-button"
          />
        </Form.Item>
        <div>
          <p className="mb-4">{t('dashboardBlankMessage')}</p>
          <p>{t('learnMore')}</p>
          <p>
            <a
              style={{ color: '#1b82ab' }}
              href="https://www.pieforproviders.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {'www.pieforproviders.com'}
            </a>
          </p>
        </div>
      </Form>
    </main>
  )
}
