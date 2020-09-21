import React, { useEffect, useState } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { Form, Input } from 'antd'
import { PaddedButton } from '_shared/PaddedButton'
import useApiResponse from '_shared/_hooks/useApiResponse'
import {
  revokeAuthentication,
  setAuthentication
} from '_utils/authenticationHandler'

export const NewPassword = () => {
  const [loading, setLoading] = useState(false)
  const { makeRequest } = useApiResponse()
  let history = useHistory()
  const location = useLocation()
  const { t } = useTranslation()

  useEffect(() => {
    const verifyPasswordToken = async () => {
      const params = new URLSearchParams(location.search)
      const token = params.get('reset_password_token')
      if (!token) {
        history.push({
          pathname: '/login',
          state: {
            error: {
              status: 422,
              attribute: 'reset_password_token',
              type: 'blank'
            }
          }
        })
      }
    }
    verifyPasswordToken()
  }, [history, location.search])

  const onFinish = async values => {
    const { password } = values
    const params = new URLSearchParams(location.search)
    const token = params.get('reset_password_token')
    setLoading(true)

    const response = await makeRequest({
      type: 'put',
      url: '/password',
      data: {
        user: {
          reset_password_token: token,
          password: password,
          password_confirmation: password
        }
      }
    })

    setLoading(false)

    const data = await response.json()

    if (!response.ok) {
      history.push({
        pathname: '/login',
        state: {
          error: {
            status: response.status,
            attribute: data.attribute,
            type: data.type
          }
        }
      })
      return
    }

    const authorizationHeader = response.headers.get('authorization')
    if (!authorizationHeader) {
      revokeAuthentication()
      // Unconfirmed users
      history.push({
        pathname: '/login',
        state: {
          error: {
            status: 401,
            attribute: 'email',
            type: 'unconfirmed',
            context: { email: data.email }
          }
        }
      })
    } else {
      setAuthentication(
        authorizationHeader /*, expiration: parse the JWT for its expiration time */
      )
      history.push('/getting-started')
    }
  }

  return (
    <>
      <p className="mb-8">
        <span className="uppercase font-bold">{t('resetPassword')}</span>
      </p>

      <Form
        layout="vertical"
        name="passwordReset"
        onFinish={onFinish}
        wrapperCol={{ lg: 12 }}
      >
        <Form.Item
          name="password"
          label={t('newPassword')}
          rules={[
            {
              required: true,
              message: t('passwordRequired')
            },
            {
              pattern: /^(?=.*\d)(?=.*[a-zA-Z]).{8,}$/,
              message: t('passwordInvalid')
            }
          ]}
          hasFeedback
        >
          <Input.Password
            placeholder={t('passwordPlaceholder')}
            data-cy="password"
          />
        </Form.Item>

        <Form.Item
          name="passwordConfirmation"
          label={t('confirmNewPassword')}
          dependencies={['password']}
          hasFeedback
          rules={[
            { required: true, message: t('passwordConfirmationRequired') },
            ({ getFieldValue }) => ({
              validator(rule, value) {
                if (!value || getFieldValue('password') === value) {
                  return Promise.resolve()
                }
                return Promise.reject(t('passwordConfirmationMatch'))
              }
            })
          ]}
        >
          <Input.Password
            placeholder={t('passwordConfirmationPlaceholder')}
            data-cy="passwordConfirmation"
          />
        </Form.Item>

        <Form.Item>
          <PaddedButton
            classes="mt-2"
            text={t('resetPassword')}
            disabled={loading}
            data-cy="resetPasswordBtn"
          />
        </Form.Item>
      </Form>
    </>
  )
}
