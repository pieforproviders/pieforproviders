import React, { useState, useEffect } from 'react'
import { Link, useHistory, useLocation } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Form, Input, Alert, Modal } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { PasswordResetRequest } from '../PasswordReset'
import ErrorAlert from 'ErrorAlert'

export function Login() {
  const location = useLocation()
  const [apiError, setApiError] = useState(null)
  const [apiSuccess, setApiSuccess] = useState(null)
  const [showResetPasswordDialog, setShowResetPasswordDialog] = useState(false)
  const { makeRequest } = useApiResponse()
  let history = useHistory()
  const { t } = useTranslation()

  useEffect(() => {
    if (location.state?.error?.status) {
      setApiSuccess(null)
      setApiError({
        status: location.state?.error?.status,
        message: location.state?.error?.message,
        attribute: location.state?.error?.attribute,
        context: location.state?.error?.context,
        type: location.state?.error?.type
      })
      window.history.replaceState(null, '')
    }
  }, [location])

  useEffect(() => {
    if (location.state?.success) {
      setApiError(null)
      setApiSuccess({
        message: location.state.success.message
      })
      window.history.replaceState(null, '')
    }
  }, [location])

  const onFinish = async values => {
    setApiSuccess(null)
    setApiError(null)
    const response = await makeRequest({
      type: 'post',
      url: '/login',
      data: { user: values }
    })
    if (!response.ok || response.headers.get('authorization') === null) {
      const errorMessage = await response.json()
      setApiError({
        status: response.status,
        message: errorMessage.error,
        attribute: errorMessage.attribute,
        type: errorMessage.type,
        context: { email: values.email }
      })
    } else {
      localStorage.setItem('pie-token', response.headers.get('authorization'))
      history.push('/getting-started')
    }
  }

  const onChooseReset = () => {
    localStorage.removeItem('pie-token')
    history.push('/dashboard')
  }
  return (
    <>
      <p className="mb-4">
        <Link to="/signup" className="uppercase">
          {t('signup')}
        </Link>{' '}
        {t('or')} <span className="uppercase font-bold">{t('login')}</span>
      </p>

      {apiError && (
        <Alert
          className="mb-2"
          message={
            <ErrorAlert
              attribute={apiError.attribute}
              type={apiError.type}
              context={apiError.context}
            />
          }
          type="error"
          data-cy="authError"
        />
      )}

      {apiSuccess && (
        <Alert
          message={apiSuccess.message}
          type="success"
          className="mb-2"
          data-cy="successMessage"
        />
      )}

      <Form
        layout="vertical"
        name="login"
        onFinish={onFinish}
        wrapperCol={{ md: 12 }}
      >
        <Form.Item
          className="text-primaryBlue"
          label={t('email')}
          name="email"
          rules={[
            {
              required: true,
              message: t('emailAddressRequired')
            },
            {
              type: 'email',
              message: t('emailInvalid')
            }
          ]}
        >
          <Input autoComplete="username" data-cy="email" />
        </Form.Item>

        <Form.Item
          className="text-primaryBlue"
          label={t('password')}
          name="password"
          rules={[
            {
              required: true,
              message: t('passwordRequired')
            }
          ]}
        >
          <Input.Password autoComplete="current-password" data-cy="password" />
        </Form.Item>

        <Form.Item>
          <PaddedButton classes="mt-2" text={t('login')} data-cy="loginBtn" />
        </Form.Item>
      </Form>
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
          <PaddedButton
            type="secondary"
            htmlType="button"
            text={t('resetPassword')}
            onClick={() => {
              setShowResetPasswordDialog(true)
            }}
            data-cy="resetPasswordBtn"
          />
        </Form.Item>
      </Form>

      {showResetPasswordDialog && (
        <Modal
          centered
          visible
          maskClosable
          footer={null}
          maskStyle={{
            backgroundColor: 'rgba(0, 74, 110, 0.5)'
          }}
          onCancel={() => setShowResetPasswordDialog(false)}
        >
          <PasswordResetRequest
            onClose={() => setShowResetPasswordDialog(false)}
          />
        </Modal>
      )}
    </>
  )
}
