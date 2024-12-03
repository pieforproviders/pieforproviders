import React, { useState, useEffect } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Form, Input, Alert, Modal } from 'antd'
import useHotjar from 'react-use-hotjar'
import { PaddedButton } from '_shared/PaddedButton'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { PasswordResetRequest } from '../PasswordReset'
import AuthStatusAlert from 'AuthStatusAlert'
import { batch, useDispatch } from 'react-redux'
import { addAuth, removeAuth } from '_reducers/authReducer'
import { setUser } from '_reducers/userReducer'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'

export function Login() {
  const dispatch = useDispatch()
  const location = useLocation()
  const { sendGAEvent } = useGoogleAnalytics()
  const { identifyHotjar } = useHotjar()
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
    const authToken = response.headers.get('authorization')
    if (!response.ok || authToken === null) {
      const errorMessage = await response.json()
      setApiError({
        status: response.status,
        message: errorMessage.error,
        attribute: errorMessage.attribute,
        type: errorMessage.type,
        context: { email: values.email }
      })
    } else {
      const resp = await response.json()

      batch(() => {
        dispatch(addAuth(authToken))
        dispatch(setUser(resp))
        identifyHotjar(resp.id ?? null, resp, console.info)
      })

      sendGAEvent('login success', { userId: resp.id })

      // currently only users from Nebraska are directed to the dashboard
      if (resp.state === 'NE' || resp.state === 'IL') {
        history.push('/dashboard')
      } else {
        history.push('/comingsoon')
      }
    }
  }

  const onChooseReset = () => {
    dispatch(removeAuth())
    history.push('/dashboard')
  }

  return (
    <main className="text-center">
      <div className="mb-8">
        <h1 className="h1-large leading-8">{t('gettingStartedWelcome')}</h1>
        <h2 className="mt-2 mb-5 eyebrow-small">{t('signupNote')}</h2>
        <div className="m-10">
          <h1 className="inline-block font-bold uppercase">{t('login')}</h1>
        </div>
      </div>
      {apiError && (
        <Alert
          className="mb-2"
          message={
            <AuthStatusAlert
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
        className="mb-6 md:mx-20 login"
      >
        <Form.Item
          className="body-2-bold text-primaryBlue"
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
          className="body-2-bold text-primaryBlue"
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
          <PaddedButton
            classes="mt-2 bg-green1 border-green1 w-full login-button"
            text={t('login')}
            data-cy="loginBtn"
          />
        </Form.Item>
        <p className="m-4 text-green3">{t('dontHaveAnAccount')}</p>
        <PaddedButton
          data-cy="signupBtn"
          text={t('signup')}
          classes="bg-white text-green3 border-green3 mb-4 w-full signup-button"
          onClick={() => history.push('/')}
        />
        <div className="text-black">
          <p>{t('learnMore')}</p>
          <p>
            <a
              href="https://www.pieforproviders.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {'www.pieforproviders.com'}
            </a>
          </p>
        </div>
      </Form>
      <Form
        layout="vertical"
        name="reset-password"
        onFinish={onChooseReset}
        className="my-10"
      >
        <div className="mb-6">
          <div className="mb-1 h3-large text-primaryBlue">
            {t('forgotPassword')}
          </div>
          <div className="body-2-bold text-primaryBlue">
            {t('resetPasswordText')}
          </div>
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
          open
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
    </main>
  )
}
