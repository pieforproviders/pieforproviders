import React from 'react'
import { Row, Col, Grid, Typography, Space } from 'antd'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { useMultiBusiness } from '_shared/_hooks/useMultiBusiness'

const { Title, Text } = Typography
const { useBreakpoint } = Grid

export function Profile() {
  const { t } = useTranslation()
  const screens = useBreakpoint()
  const user = useSelector(state => state.user)
  const { isMultiBusiness } = useMultiBusiness()

  const business = user.businesses?.length ? user.businesses[0] : null

  function getColSpan() {
    if (screens.xs) return 24
    if (screens.xl) return 6
    if (screens.lg) return 8
    if (screens.md) return 8
    return 12
  }

  return (
    <Row gutter={[16, 32]}>
      <Col span={getColSpan()}>
        <Space direction="vertical" width="100%" size="middle">
          <Title level={5} size="" className="text-primaryBlue">
            {t('personalDetails')}
          </Title>
          {screens.xs && (
            <Space direction="vertical">
              <Text strong>{t('fullName')}</Text>
              <Text>{user.full_name}</Text>
            </Space>
          )}
          <Space direction="vertical">
            <Text strong>{t('preferredName')}</Text>
            <Text>{user.greeting_name}</Text>
          </Space>
          <Space direction="vertical">
            <Text strong>{t('phone')}</Text>
            <Text>{user.phone_number}</Text>
          </Space>
          <Space direction="vertical">
            <Text strong>{t('emailAddress')}</Text>
            <Text>{user.email}</Text>
          </Space>
          <Space direction="vertical">
            <Text strong>{t('preferredLanguage')}</Text>
            <Text>{user.language === 'es' ? t('spanish') : t('english')}</Text>
          </Space>
        </Space>
      </Col>
      {business && (
        <Col span={getColSpan()}>
          <Space direction="vertical" size="middle">
            <Title level={5} size="" className="text-primaryBlue">
              {t('businessDetails')}
            </Title>
            {screens.xs && (
              <Space direction="vertical">
                <Text strong>{t('organizationName')}</Text>
                <Text>{business.name}</Text>
              </Space>
            )}
            <Space direction="vertical">
              <Text strong>{t('accountType')}</Text>
              <Text>
                {isMultiBusiness
                  ? t('multiBusinessProfile')
                  : t('singleBusinessProfile')}
              </Text>
            </Space>
            <Space direction="vertical">
              <Text strong>{t('licenseType')}</Text>
              <Text>{business.license_type}</Text>
            </Space>
            <Space direction="vertical">
              <Text strong>{t('location')}</Text>
              <Text>{`${business.county}, ${business.zipcode}`}</Text>
            </Space>
            <Space direction="vertical">
              <Text strong>{t('qrisRating')}</Text>
              <Text>{business.qris_rating}</Text>
            </Space>
            <Space direction="vertical">
              <Text strong>{t('accreditedQuestion')}</Text>
              <Text>{business.accredited}</Text>
            </Space>
          </Space>
        </Col>
      )}
    </Row>
  )
}
