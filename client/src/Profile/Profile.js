import React from 'react'
import { Row, Col, Grid, Typography, Space } from 'antd'
import { useTranslation } from 'react-i18next'

const { Title, Text } = Typography
const { useBreakpoint } = Grid

export function Profile() {
  const { t } = useTranslation()
  const screens = useBreakpoint()

  function getColSpan() {
    if (screens.xs) return 24
    if (screens.xl) return 6
    if (screens.lg) return 8
    if (screens.md) return 8
    return 12
  }

  return (
    <Row gutter={[16, 16]}>
      <Col span={getColSpan()}>
        <Space direction="vertical" width="100%">
          <Title level={5} size="" className="text-primaryBlue">
            {t('personalDetails')}
          </Title>
          {screens.xs && (
            <>
              <Text strong>{t('fullName')}</Text>
              <Text>Test</Text>
            </>
          )}
          <Text strong>{t('preferredName')}</Text>
          <Text>Test</Text>
          <Text strong>{t('phone')}</Text>
          <Text>Test</Text>
          <Text strong>{t('emailAddress')}</Text>
          <Text>Test</Text>
          <Text strong>{t('preferredLanguage')}</Text>
          <Text>Test</Text>
        </Space>
      </Col>
      <Col span={getColSpan()}>
        <Space direction="vertical">
          <Title level={5} size="" className="text-primaryBlue">
            {t('businessDetails')}
          </Title>
          {screens.xs && (
            <>
              <Text strong>{t('organizationName')}</Text>
              <Text>Test</Text>
            </>
          )}
          <Text strong>{t('accountType')}</Text>
          <Text>Test</Text>
          <Text strong>{t('licenseType')}</Text>
          <Text>Test</Text>
          <Text strong>{t('location')}</Text>
          <Text>Test</Text>
          <Text strong>{t('qrisRating')}</Text>
          <Text>Test</Text>
          <Text strong>{t('accreditedQuestion')}</Text>
          <Text>Test</Text>
        </Space>
      </Col>
    </Row>
  )
}
