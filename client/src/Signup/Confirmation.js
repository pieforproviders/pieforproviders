import React from 'react'
import PropTypes from 'prop-types'
import { Divider, Typography } from 'antd'
import LabelImportantIcon from '@material-ui/icons/LabelImportant'

const { Title, Text, Link } = Typography

// TODO: placeholder for actual user's email that signed up
const userEmail = 'chelsea@pieforproviders.com'
const pieEmail = 'noreply@pieforproviders.com'

function ListItem({ children }) {
  return (
    <div className="flex align-center justify-left mb-1">
      <LabelImportantIcon
        className="mr-1"
        style={{ color: '#000', width: '16px' }}
      />
      {children}
    </div>
  )
}

const Confirmation = () => {
  return (
    <>
      <Title>Thanks for signing up!</Title>
      <Title level={3}>We’ve sent you an email to verify your account.</Title>
      <Divider />
      <div className="text-left">
        <div className="mb-2">
          <Text>Didn't receive the email?</Text>
        </div>
        <ListItem>
          <Text>
            Is {userEmail} your correct email without typos? If not, you can
            restart the signup process.
          </Text>
        </ListItem>
        <ListItem>
          <Text>Check your spam folder</Text>
        </ListItem>
        <ListItem>
          <Text>
            Add <Text underline={true}>{pieEmail}</Text> to your contacts.
          </Text>
        </ListItem>
        <ListItem>
          <Link to="#">Click here to resend the email.</Link>
        </ListItem>
      </div>
    </>
  )
}

ListItem.propTypes = {
  children: PropTypes.element.isRequired
}

export default Confirmation
