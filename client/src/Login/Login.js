import React, { useState, useEffect } from 'react'
import { Link, useHistory, useLocation } from 'react-router-dom'
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

export function Login() {
  const dispatch = useDispatch()
  const location = useLocation()
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

      // currently only users from Nebraska are directed to the dashboard
      if (resp.state === 'NE') {
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
        <h1 className="h1-large">{t('gettingStartedWelcome')}</h1>
        <h2 className="mb-5 eyebrow-small">{t('signupNote')}</h2>
        <div className="m-10">
          <Link to="/signup" className="uppercase">
            {t('signup')}
          </Link>{' '}
          {t('or ')}
          <h1 className="uppercase font-bold inline-block">{t('login')}</h1>
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
        className="mb-6 ml-20 mr-20 signup"
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
      </Form>
      <div className="mx-20 mb-6">
        <p className="text-green3 m-4">{t('dontHaveAnAccount')}</p>
        <PaddedButton
          data-cy="signupBtn"
          text={'Signup'}
          classes="bg-white text-green3 border-green3 mb-4 w-full signup-button"
          onClick={() => history.push('/signup')}
        />
        <div className="text-black">
          <p className="mb-4">{t('dashboardBlankMessage')}</p>
          <p>{t('learnMore')}</p>
          <p>
            <a
              className="text-blue5"
              href="https://www.pieforproviders.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {'www.pieforproviders.com'}
            </a>
          </p>
        </div>
      </div>
      <Form
        layout="vertical"
        name="reset-password"
        onFinish={onChooseReset}
        className="my-10"
      >
        <div className="mb-6">
          <div className="h3-large mb-1 text-primaryBlue">
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
    </main>
  )
}
