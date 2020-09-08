import React from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'

export const ResendToken = ({ type }) => {
  const { t } = useTranslation()

  return (
    <div>
      {`${t('yourConfirmationToken')} ${t(type)}. ${t(
        'mustUseConfirmationEmail'
      )} ${t('requestNewConfirmation')} `}
      <a href="www.google.com" target="_blank">
        Placeholder Link
      </a>
    </div>
  )
}

ResendToken.propTypes = {
  type: PropTypes.string.isRequired
}
