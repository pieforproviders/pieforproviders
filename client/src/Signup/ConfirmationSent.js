import React from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import { Divider, Typography, message } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import LabelImportantIcon from '@material-ui/icons/LabelImportant'

const { Title, Text, Link } = Typography

const pieEmail = 'tech@pieforproviders.com'

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
  const { makeRequest } = useApiResponse()

  const resendConfirmation = async () => {
    const response = await makeRequest({
      type: 'post',
      url: `confirmation?email=${userEmail}`
    })
    if (response?.error) {
      message.error(response.error)
    } else {
      message.success('Email resent!')
    }
  }

  return (
    <>
      <Title className="text-center">{t('signupThanks')}</Title>
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
            {t('add')} <Text underline={true}>{pieEmail}</Text>{' '}
            {t('addToContacts')}
          </Text>
        </ListItem>
        <ListItem id="resend-link">
          <Link onClick={resendConfirmation}>
            {t('resendConfirmationEmail')}
          </Link>
        </ListItem>
      </div>
    </>
  )
}

ConfirmationSent.propTypes = {
  userEmail: PropTypes.string.isRequired
}

export default ConfirmationSent
