import React from 'react'
import { useHistory } from 'react-router-dom'
import { Form, Input, Button, Checkbox } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'

export function Login() {
  const { makeRequest } = useApiResponse()
  let history = useHistory()

  const onFinish = async values => {
    const response = await makeRequest({
      type: 'post',
      url: '/login',
      data: { user: values }
    })
    localStorage.setItem('token', response.headers.get('authorization'))
    // if unauthorized, redirect to /login with error
    // if authorized, redirect to /dashboard
    if (response.headers.get('authorization') !== null) {
      console.log('token: ', localStorage.getItem('token'))
      history.push('/dashboard')
    } else {
      console.log('error logging in')
    }
  }

  const onFinishFailed = errorInfo => {
    // TODO: this handles error states on the fields
    console.log('Failed:', errorInfo)
  }
  return (
    <div className="login">
      <Form
        name="login"
        initialValues={{ remember: true }}
        onFinish={onFinish}
        onFinishFailed={onFinishFailed}
      >
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
