import React from 'react'
import PropTypes from 'prop-types'
import ResendToken from 'ResendToken'
import { useTranslation } from 'react-i18next'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'

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

const resendToken = type => <ResendToken type={type} />
const contactUs = message => <ContactUs message={message} />

export const ErrorAlert = ({ attribute, type }) => {
  const { t } = useTranslation()

  const errorMessages = {
    email: {
      already_confirmed: () => t('alreadyConfirmed'),
      confirmation_period_expired: () => t('confirmationPeriodExpired'),
      not_confirmed: () => t('emailUnconfirmed'),
      not_found: () => t('emailNotFound'),
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

ErrorAlert.propTypes = {
  attribute: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired
}
