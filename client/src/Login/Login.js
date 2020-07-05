import React, { useState } from 'react'
import { useHistory } from 'react-router-dom'
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
    console.log('response:', response)
    if (!response.ok) {
      // TODO: Sentry
      setApiError(response.json().error || 'error')
    } else if (response.ok && response.headers.get('authorization') !== null) {
      localStorage.setItem('token', response.headers.get('authorization'))
      history.push('/dashboard')
    } else {
      // TODO: Sentry
      // This is an OK response without an auth token
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
          <Input.Password autoComplete="current-password" />
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
