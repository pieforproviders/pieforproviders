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
    // This is returning undefined when I use invalid creds and get a 401
    console.log('response:', response)
    // if (!response.ok) {
    //   // TODO: Sentry
    //   switch (response.error) {
    //     case null:
    //       break
    //     case 404:
    //       setApiError('API not found - contact a site administrator')
    //       break
    //     case /You must sign in or sign up to continue/:
    //       setApiError(response.error)
    //       break
    //   }
    // } else if (response.ok && response.headers.get('authorization') !== null) {
    //   localStorage.setItem('token', response.headers.get('authorization'))
    //   history.push('/dashboard')
    // } else {
    //   // TODO: Sentry
    //   setApiError('An unknown error occurred - please try again later')
    // }
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
