import React, { useState } from 'react'
import { Link, useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Form, Input, Alert } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Login() {
  const [apiError, setApiError] = useState(null)
  const { makeRequest } = useApiResponse()
  let history = useHistory()
  const { t, i18n } = useTranslation()

  const onFinish = async values => {
    const response = await makeRequest({
      type: 'post',
      url: '/login',
      data: { user: values },
      headers: { 'Accept-Language': i18n.language }
    })
    if (!response.ok || response.headers.get('authorization') === null) {
      const errorMessage = await response.json()
      setApiError({
        status: response.status,
        message: errorMessage.error
      })
    } else {
      localStorage.setItem('pie-token', response.headers.get('authorization'))
      history.push('/dashboard')
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
          message={apiError.message}
          type="error"
          data-cy="loginError"
        />
      )}

      <Form
        layout="vertical"
        name="login"
        onFinish={onFinish}
        wrapperCol={{ lg: 12 }}
      >
        <Form.Item
          className="text-primaryBlue"
          label={t('email')}
          name="email"
          rules={[
            {
              required: true,
              message: t('emailAddressRequired')
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
          />
        </Form.Item>
      </Form>
    </>
  )
}
