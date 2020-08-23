import React, { useState } from 'react'
import { useHistory } from 'react-router-dom'
import { Form, Button, Alert } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useTranslation } from 'react-i18next'

export function Confirmation({ location }) {
  const [apiError, setApiError] = useState(null)
  const { makeRequest } = useApiResponse()
  let history = useHistory()
  const { t } = useTranslation()

  //location.search.split('=')[1]

  const confirm = async () => {
    const token = location.search.split('=')[1]
    const response = await makeRequest({
      type: 'get',
      url: `${location.pathname}?confirmation_token=${token}`
    })
    if (!response.ok || response.headers.get('authorization') === null) {
      console.log('response not okay')
      const errorMessage = await response.json()
      console.log('errorMessage:', errorMessage)
      setApiError({
        status: response.status,
        message: errorMessage.error
      })
      localStorage.removeItem('pie-token')
      // history.push('/login')
    } else {
      console.log('response okay')
      localStorage.setItem('pie-token', response.headers.get('authorization'))
      history.push('/getting-started')
    }
  }

  const onChooseReset = () => {
    localStorage.removeItem('pie-token')
    // TODO: this will be a push to reset-password
    history.push('/dashboard')
  }

  // confirm()

  return (
    <>
      {apiError && (
        <>
          <Alert
            className="mb-2"
            message={`${apiError.message} There was an error with your confirmation, please reset your password below.`}
            type="error"
          />
          <Form
            layout="vertical"
            name="reset-password"
            onFinish={onChooseReset}
            className="mt-24"
          >
            <div className="mb-6">
              <div className="text-2xl font-semibold mb-1 text-primaryBlue">
                {t('forgotPassword')}
              </div>
              <div>{t('resetPasswordText')}</div>
            </div>
            <Form.Item>
              <Button
                type="secondary"
                htmlType="button"
                shape="round"
                className="font-semibold uppercase"
              >
                {t('resetPassword')}
              </Button>
            </Form.Item>
          </Form>
        </>
      )}
    </>
  )
}
