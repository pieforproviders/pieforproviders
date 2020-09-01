import React from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import { Divider, Typography } from 'antd'
import LabelImportantIcon from '@material-ui/icons/LabelImportant'

const { Title, Text, Link } = Typography

const pieEmail = 'tech@pieforproviders.com'

function ListItem({ children }) {
  return (
    <div className="flex justify-left mb-2">
      <LabelImportantIcon
        className="mr-1"
        style={{ color: '#000', fontSize: '16px' }}
      />
      {children}
    </div>
  )
}

ListItem.propTypes = {
  children: PropTypes.element.isRequired
}

const ConfirmationSent = ({ userEmail }) => {
  const { t } = useTranslation()

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
        <ListItem>
          <Link to="#">{t('resendConfirmationEmail')}</Link>
        </ListItem>
      </div>
    </>
  )
}

ConfirmationSent.propTypes = {
  userEmail: PropTypes.string.isRequired
}

export default ConfirmationSent
