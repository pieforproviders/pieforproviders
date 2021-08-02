import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Divider, Typography, Alert } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import LabelImportantIcon from '@material-ui/icons/LabelImportant'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'

const { Title, Text, Link } = Typography

function ListItem({ children, id = null }) {
  return (
    <div id={id} className="flex justify-left mb-2">
      <LabelImportantIcon
        className="mr-1"
        style={{ color: '#000', fontSize: '16px' }}
      />
      {children}
    </div>
  )
}

ListItem.propTypes = {
  children: PropTypes.element.isRequired,
  id: PropTypes.string
}

const ConfirmationSent = ({ userEmail }) => {
  const { t } = useTranslation()
  const history = useHistory()
  const { makeRequest } = useApiResponse()
  const [resent, setResent] = useState(null)

  const resendConfirmation = async () => {
    setResent(null)
    const response = await makeRequest({
      type: 'post',
      url: '/confirmation',
      data: {
        user: {
          email: userEmail
        }
      }
    })
    if (response.ok) {
      setResent(true)
    } else {
      const errorMessage = await response.json()
      history.push({
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
    <>
      <Title className="text-center" data-cy="signupThanks">
        {t('signupThanks')}
      </Title>
      <Title level={3} className="text-center">
        {t('emailVerificationText')}
      </Title>
      <Divider />
      <div className="text-left">
        <div className="mb-2">
          <Text>{t('emailNotReceived')}</Text>
        </div>
        <ListItem>
          <Text>{t('restartSignup', { userEmail })}</Text>
        </ListItem>
        <ListItem>
          <Text>{t('checkSpam')}</Text>
        </ListItem>
        <ListItem>
          <Text>
            {t('add')} <Text underline={true}>{PIE_FOR_PROVIDERS_EMAIL}</Text>{' '}
            {t('addToContacts')}
          </Text>
        </ListItem>
        <ListItem id="resend-link">
          <Link data-cy="resendConfirmation" onClick={resendConfirmation}>
            {t('resendConfirmationEmail')}
          </Link>
        </ListItem>
        {resent && (
          <Alert
            message={t('confirmationEmailResent')}
            type="success"
            data-cy="resent"
            show-icon
          />
        )}
      </div>
    </>
  )
}

ConfirmationSent.propTypes = {
  userEmail: PropTypes.string.isRequired
}

export default ConfirmationSent
