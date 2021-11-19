import React from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import ResendToken from 'ResendToken'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import { Link } from 'react-router-dom'

const ContactUs = ({ message }) => {
  const { t } = useTranslation()
  return (
    <>
      {message}{' '}
      <a href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}>{t('contactUs')}</a>{' '}
      {t('forSupport')}
    </>
  )
}

ContactUs.propTypes = {
  message: PropTypes.string.isRequired
}

const showConfirmationAlert = email => <ConfirmationAlert email={email} />
const resendToken = type => <ResendToken type={type} />
const contactUs = message => <ContactUs message={message} />

const ConfirmationAlert = ({ email }) => {
  const { t } = useTranslation()
  const history = useHistory()
  const { makeRequest } = useApiResponse()

  const resendConfirmation = async () => {
    const response = await makeRequest({
      type: 'post',
      url: '/confirmation',
      data: {
        email
      }
    })
    if (response.ok) {
      history.replace({
        pathname: '/login',
        state: {
          success: {
            message: t('confirmationEmailResent')
          }
        }
      })
    } else {
      const errorMessage = await response.json()
      history.replace({
        pathname: '/login',
        state: {
          error: {
            status: response.status,
            message: errorMessage.error,
            attribute: errorMessage.attribute,
            type: errorMessage.type
          }
        }
      })
    }
  }

  return (
    <div>
      {t('emailUnconfirmed')}{' '}
      <Link
        to="#"
        onClick={resendConfirmation}
        data-cy="resendConfirmationLink"
      >
        {t('clickHere')}
      </Link>{' '}
      {t('toResendConfirmationEmail')}
    </div>
  )
}

ConfirmationAlert.propTypes = {
  email: PropTypes.string.isRequired
}

export const AuthStatusAlert = ({ attribute, context, type }) => {
  const { t } = useTranslation()

  const errorMessages = {
    email: {
      unauthenticated: () => t('unauthenticated'),
      already_confirmed: () => t('alreadyConfirmed'),
      confirmation_period_expired: () => t('confirmationPeriodExpired'),
      unconfirmed: () => showConfirmationAlert(context?.email),
      not_found: () => t('emailNotFound'),
      invalid: () => t('invalidEmailOrPassword'),
      not_found_in_database: () => t('invalidEmailOrPassword'),
      default: () => contactUs(t('genericEmailConfirmationError'))
    },
    confirmation_token: {
      blank: () => resendToken('blank'),
      invalid: () => resendToken('invalid'),
      default: () => contactUs(t('genericEmailConfirmationError'))
    },
    reset_password_token: {
      blank: () => t('passwordResetTokenBlank'),
      invalid: () => t('passwordResetTokenInvalid'),
      expired: () => t('passwordResetTokenExpired')
    },
    default: () => t('genericConfirmationError')
  }

  const attributeError = errorMessages[attribute]
  if (!attributeError) {
    return errorMessages.default()
  }
  const alert = attributeError[type] || attributeError.default
  return alert()
}

AuthStatusAlert.defaultProps = {
  context: null
}

AuthStatusAlert.propTypes = {
  attribute: PropTypes.string.isRequired,
  context: PropTypes.shape({
    email: PropTypes.string.isRequired
  }),
  type: PropTypes.string.isRequired
}
