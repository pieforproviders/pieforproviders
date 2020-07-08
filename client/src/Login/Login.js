import React, { useState } from 'react'
import { Link, useHistory } from 'react-router-dom'
import { Form, Input, Button, Col, Row } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import piefulltanlogo from '_assets/piefulltanlogo.svg'
import kid1 from '_assets/kid1.png'

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

  return (
    <Row>
      <Col xs={{ span: 0 }} lg={{ span: 12 }} className="h-screen kid-image" />
      <Col lg={{ span: 12 }}>
        {/* TODO: language switcher */}
        <p>English</p>
        <img alt="Pie for Providers logo" src={piefulltanlogo} />
        <h1>Log In</h1>
        <p>
          Sign Up or <Link to="/login">Log In</Link>
        </p>
        <Form name="login" onFinish={onFinish}>
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
            <Button type="primary" htmlType="submit">
              Submit
            </Button>
          </Form.Item>
        </Form>
      </Col>
    </Row>
  )
}
