import React, { useState } from 'react'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Button, Checkbox } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Login() {
  const [apiError, setApiError] = useState(null)
  const { makeRequest } = useApiResponse()
  let history = useHistory()

  const onFinish = async values => {
    const response = await makeRequest({
      type: 'post',
      url: '/login',
      data: { user: values }
    })
    if (!response.ok) {
      // TODO: Sentry
      switch (response.status) {
        case 401:
          setApiError(
            <p>
              Your credentials were incorrect, please try again. Or{' '}
              <Link to="/reset-password">reset your password</Link>
            </p>
          )
          break
        case 404:
          setApiError('API not found - contact a site administrator')
          break
        default:
          setApiError('WHERPS')
          break
      }
    } else if (response.ok && response.headers.get('authorization') !== null) {
      localStorage.setItem('token', response.headers.get('authorization'))
      history.push('/dashboard')
    } else {
      // TODO: Sentry
      setApiError('An unknown error occurred - please try again later')
    }
  }

  return (
    <div className="login">
      {apiError && <div>{apiError}</div>}
      <Form name="login" initialValues={{ remember: true }} onFinish={onFinish}>
        <Form.Item
          label="Email"
          name="email"
          rules={[
            {
              required: true,
              message: 'Email address is required'
            }
          ]}
        >
          <Input />
        </Form.Item>

        <Form.Item
          label="Password"
          name="password"
          rules={[
            {
              required: true,
              message: 'Password is required'
            }
          ]}
        >
          <Input.Password />
        </Form.Item>

        <Form.Item name="remember" valuePropName="checked">
          <Checkbox>Remember me</Checkbox>
        </Form.Item>

        <Form.Item>
          <Button type="primary" htmlType="submit">
            Submit
          </Button>
        </Form.Item>
      </Form>
    </div>
  )
}
