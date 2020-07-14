import React, { useState } from 'react'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Button } from 'antd'
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
          Sign Up
        </Link>{' '}
        or <span className="uppercase font-bold">Log In</span>
      </p>
      <Form layout="vertical" name="login" onFinish={onFinish}>
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
          <Input autoComplete="username" />
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

        {apiError && (
          <div>
            <div>{apiError.message}</div>
            {apiError.status === 401 && (
              <Link to={'/reset-password'}>Reset Password?</Link>
            )}
          </div>
        )}

        <Form.Item>
          <Button type="primary" htmlType="submit" className="font-semibold">
            Submit
          </Button>
        </Form.Item>
      </Form>
      <Form
        layout="vertical"
        name="reset-password"
        onFinish={onChooseReset}
        className="mt-24"
      >
        <div className="mb-6">
          <div className="text-2xl font-semibold mb-1">
            Forgot your password?
          </div>
          <div>
            No worries. Click the button below and check your email to reset it.
          </div>
        </div>
        <Form.Item>
          <Button type="primary" htmlType="button" className="font-semibold">
            Reset Password
          </Button>
        </Form.Item>
      </Form>
    </>
  )
}
