import React from 'react'
import { Avatar, Row, Col, Grid, Typography, Space, Divider } from 'antd'
import EditIcon from '@material-ui/icons/Edit'
import LockIcon from '@material-ui/icons/Lock'
import { useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'
import { useMultiBusiness } from '_shared/_hooks/useMultiBusiness'
import IconButton from './IconButton'

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

  const mobileHeader = (
    <>
      {Object.keys(user).length !== 0 && (
        <div className="mb-10">
          <div className="flex justify-center">
            <Title>{t('myProfile')}</Title>
          </div>
          <div className="flex justify-center">
            <Avatar
              className="bg-primaryBlue"
              size={64}
              style={{ fontSize: 28 }}
            >
              {user.greeting_name[0]}
            </Avatar>
          </div>
        </div>
      )}
    </>
  )

  const desktopHeader = (
    <>
      {Object.keys(user).length !== 0 && (
        <div className="mb-10">
          <div className={`flex ${screens.md ? '' : 'justify-between'}`}>
            <div>
              <Title style={{ marginBottom: 0 }}>{t('myProfile')}</Title>
            </div>
            <div className="flex items-center">
              <IconButton
                className="ml-5 text-base"
                icon={<EditIcon />}
                text={screens.md ? 'Edit' : 'Edit Profile'}
                onClick={() => null}
              />
            </div>
          </div>
          <Divider style={{ marginTop: 0 }} />
          <Space size="middle">
            <Avatar
              className="bg-primaryBlue"
              size={54}
              style={{ fontSize: 28 }}
            >
              {user.greeting_name[0]}
            </Avatar>
            <div>
              <Title level={2} style={{ margin: 0 }}>
                {user.full_name}
              </Title>
              {business && (
                <span className="text-lg font-semibold text-black">
                  {business.name}
                </span>
              )}
            </div>
          </Space>
        </div>
      )}
    </>
  )

  return (
    Object.keys(user).length !== 0 && (
      <div className={screens.sm ? 'pt-0 p-5' : 'pt-0 p-2'}>
        {screens.xs && mobileHeader}
        {screens.sm && desktopHeader}
        <Row gutter={[16, 32]}>
          <Col span={getColSpan()}>
            <Space direction="vertical" width="100%" size="middle">
              <Title level={5} style={{ marginBottom: 0 }}>
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
                <Text>
                  {user.language === 'es' ? t('spanish') : t('english')}
                </Text>
              </Space>
              {!screens.xs && (
                <IconButton
                  icon={<LockIcon />}
                  text="Change Password"
                  onClick={() => null}
                />
              )}
            </Space>
          </Col>
          {business && (
            <Col span={getColSpan()} style={{}}>
              <Space direction="vertical" size="middle">
                <Title level={5} style={{ marginBottom: 0 }}>
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
                  <Text>{business.accredited ? 'Yes' : 'No'}</Text>
                </Space>
              </Space>
            </Col>
          )}
          {screens.xs && (
            <Col>
              <Space direction="vertical" align="start">
                <IconButton
                  icon={<EditIcon />}
                  text="Edit Profile"
                  onClick={() => null}
                />
                <IconButton
                  icon={<LockIcon />}
                  text="Change Password"
                  onClick={() => null}
                />
              </Space>
            </Col>
          )}
        </Row>
      </div>
    )
  )
}
