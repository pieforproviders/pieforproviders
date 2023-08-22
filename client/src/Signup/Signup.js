import React, { useState } from 'react'
import { Alert, Form, Input, Radio, Checkbox } from 'antd'
import { useHistory } from 'react-router-dom'
import { PaddedButton } from '_shared/PaddedButton'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import '_assets/styles/form-overrides.css'
import '_assets/styles/next-button-overrides.css'
import RadioButtonUncheckedIcon from '@material-ui/icons/RadioButtonUnchecked'
import CheckCircleIcon from '@material-ui/icons/CheckCircle'
import i18n from 'i18n'
import ConfirmationSent from './ConfirmationSent'
import StateDropdown from './StateDropdown'
import SignupQuestion from './SignupQuestion'
import useFreshsales from '_shared/_hooks/useFreshsales'
import Select from '_shared/_components/Select/Select'
import { Option } from '_shared/_components/Select/Select'

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
    getFromPie: null,
    heardAbout: null
  })
  const { sendGAEvent } = useGoogleAnalytics()
  const [success, setSuccess] = useState(false)
  const [validationErrors, setValidationErrors] = useState(null)
  const [error, setError] = useState(false)
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()
  const history = useHistory()
  useFreshsales()

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

      sendGAEvent('signup success', { state: user.state })
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
          className="text-blue5"
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
        <h1 className="h1-large leading-8">{t('gettingStartedWelcome')}</h1>
        <h2 className="mt-2 mb-5 eyebrow-small">{t('signupNote')}</h2>
        <div className="m-10">
          <h1 className="inline-block font-bold uppercase">{t('signup')}</h1>
          {` ${t('or')} `}
          <Link to="/login" className="uppercase">
            {t('login')}
          </Link>
        </div>
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
        className="mb-20 md:mx-20 signup"
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
            name="fullName"
            onChange={event =>
              setUser({ ...user, fullName: event.target.value })
            }
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue phone"
          name="phone"
          label={`${t('phone')} (${t('phoneNote')})`}
        >
          <Input.Group compact name="phoneType">
            <label htmlFor="rc_select_1" className="sr-only">
              {t('phoneType')}
            </label>
            <Select
              id="phoneType"
              name="phoneType"
              value={user.phoneType}
              style={{ width: '30%', borderRight: '0', textAlign: 'left' }}
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
                  pattern: /^\d{10}$/,
                  message: t('phoneNumberInvalid')
                },
                {
                  required: true,
                  message: t('phoneRequired')
                }
              ]}
              hasFeedback={!!validationErrors?.phone_number}
              validateStatus={validationErrors?.phone_number && 'error'}
              help={
                validationErrors?.phone_number &&
                `${t('phone')} ${t(validationErrors.phone_number[0].error)}`
              }
            >
              <Input
                value={user.phoneNumber}
                data-cy="phoneNumber"
                name="phoneNumber"
                onChange={event =>
                  setUser({ ...user, phoneNumber: event.target.value })
                }
              />
            </Form.Item>
          </Input.Group>
        </Form.Item>

        <Form.Item
          className="mb-0 text-center body-2-bold text-primaryBlue"
          label={t('preferredLanguage')}
          valuePropName="checked"
          // explicity styling around Ant's strong "width of radio buttons" opinion
          style={{ marginBottom: '15px' }}
          rules={[
            {
              required: true,
              message: t('preferredLanguageRequired')
            }
          ]}
        >
          <Radio.Group
            value={user.language}
            optionType="button"
            buttonStyle="solid"
            className="w-full"
            name="preferredLanguage"
            onChange={event =>
              setUser({ ...user, language: event.target.value })
            }
            rules={[
              { required: true, message: t('preferredLanguageRequired') }
            ]}
          >
            <Radio.Button
              value="en"
              data-cy="languageEn"
              className="w-1/2"
              name="language"
            >
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
            <Radio.Button
              value="es"
              data-cy="languageEs"
              className="w-1/2"
              name="language"
            >
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
            name="email"
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
          className="flex mb-0 body-2-bold text-primaryBlue questions"
          label={t('helpUsUnderstand')}
        >
          {/* <Form.Item
            name="feelStressedQuestion"
            rules={[
              {
                required: true,
                message: t('surveyRequired')
              }
            ]}
          >
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, stressedAboutBilling: event.target.value })
              }
              questionText={t('feelStressed')}
              tag="stressed"
            />
          </Form.Item> */}
          <Form.Item
            name="moneyQuestion"
            rules={[
              {
                required: true,
                message: t('surveyRequired')
              }
            ]}
          >
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, notAsMuchMoney: event.target.value })
              }
              questionText={t('money')}
              tag="money"
            />
          </Form.Item>
          <Form.Item
            name="timeQuestion"
            rules={[
              {
                required: true,
                message: t('surveyRequired')
              }
            ]}
          >
            <SignupQuestion
              onChange={event =>
                setUser({ ...user, tooMuchTime: event.target.value })
              }
              questionText={t('time')}
              tag="time"
            />
          </Form.Item>
          {/* <Form.Item
            name="acceptingMoreQuestion"
            rules={[
              {
                required: true,
                message: t('surveyRequired')
              }
            ]}
          >
            <SignupQuestion
              onChange={event =>
                setUser({
                  ...user,
                  acceptMoreSubsidyFamilies: event.target.value
                })
              }
              questionText={t('acceptingMoreFamilies')}
              tag="moreFamilies"
            />
          </Form.Item> */}
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue optional-questions"
          name="openSignUpQuestion"
          label={t('hopeForP4P')}
        >
          <TextArea
            rows={1}
            onChange={event =>
              setUser({ ...user, getFromPie: event.target.value })
            }
            name="openSignUpQuestion"
            className="open-signup-question"
            data-cy="open-signup-question"
          />
        </Form.Item>

        <Form.Item
          className="body-2-bold text-primaryBlue optional-questions"
          name="heardAboutQuestion"
          label={t('heardAboutUs')}
        >
          <TextArea
            rows={1}
            onChange={event =>
              setUser({ ...user, heardAbout: event.target.value })
            }
            name="heardAboutQuestion"
            className="open-signup-question"
            data-cy="open-signup-question"
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
            text={t('signUp')}
            classes="bg-green1 border-green1 w-full next-button"
          />
        </Form.Item>
        <div>
          <p className="m-4 text-green3">{t('alreadyHaveAnAccount')}</p>
          <PaddedButton
            data-cy="loginBtn"
            text={t('login')}
            classes="bg-white text-green3 border-green3 mb-4 w-full signup-button"
            onClick={() => history.push('/login')}
          />
          <p className="mb-4">{t('dashboardBlankMessage')}</p>
          <p>{t('learnMore')}</p>
          <p>
            <a
              className="text-blue5"
              href="https://www.pieforproviders.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {'www.pieforproviders.com'}
            </a>
          </p>
        </div>
        <Form.Item style={{ display: 'none' }}>
          <Input
            name="lifecycle Stage"
            type="Dropdown"
            className="ant-input"
            value="Sign-up"
          />
        </Form.Item>
        <Form.Item style={{ display: 'none' }}>
          <Input
            name="Status"
            type="Dropdown"
            className="ant-input"
            value="Completed sign-up form"
          />
        </Form.Item>
      </Form>
    </main>
  )
}
