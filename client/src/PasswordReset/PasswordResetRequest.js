import React, { useState } from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import { Form, Input, Alert } from 'antd'
import ArrowBackIcon from '@material-ui/icons/ArrowBack'
import { PaddedButton } from '_shared/PaddedButton'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { ActionLink } from '../_shared/ActionLink'
import ErrorAlert from 'ErrorAlert'

export function PasswordResetRequest({ onClose }) {
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [apiError, setApiError] = useState(null)
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()

  const onFinish = async values => {
    setLoading(true)
    setApiError(null)
    setSuccess(false)
    const response = await makeRequest({
      type: 'post',
      url: '/password',
      data: { user: values }
    })
    const data = await response.json()
    if (response.ok) {
      setSuccess(true)
    } else {
      setApiError({
        status: response.status,
        attribute: data.attribute,
        type: data.type
      })
    }
    setLoading(false)
  }

  return (
    <div className="flex flex-col">
      <div className="text-center">
        <h5 className="text-2xl font-bold uppercase">{t('resetPassword')}</h5>
      </div>
      <div className="text-sm font-semibold mt-4 mb-2">
        {t('resetPasswordInstructions')}
      </div>
      {apiError && (
        <Alert
          type="error"
          message={
            <ErrorAlert attribute={apiError.attribute} type={apiError.type} />
          }
          className="mb-2"
          data-cy="errorMessage"
        />
      )}
      {success && (
        <Alert
          message={t('resetPasswordRequestSuccess')}
          type="success"
          className="mb-2"
          data-cy="successMessage"
        />
      )}
      <Form layout="vertical" name="resetPassword" onFinish={onFinish}>
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
          <Input
            autoComplete="email"
            data-cy="resetPasswordEmail"
            placeholder="amanda@gmail.com"
            className="px-5 py-3"
          />
        </Form.Item>

        <Form.Item>
          <div className="flex flex-row justify-center">
            <PaddedButton
              disabled={loading}
              text={t('reset')}
              data-cy="resetPasswordSubmitBtn"
            />
          </div>
        </Form.Item>
      </Form>

      <div className="text-center">
        <ActionLink onClick={onClose} classes="py-0">
          <>
            <ArrowBackIcon className="mr-2" />
            {t('cancel')}
          </>
        </ActionLink>
      </div>
    </div>
  )
}

PasswordResetRequest.propTypes = {
  onClose: PropTypes.func.isRequired
}
