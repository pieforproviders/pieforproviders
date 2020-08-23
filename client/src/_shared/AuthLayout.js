import React from 'react'
import PropTypes from 'prop-types'
import { useTranslation } from 'react-i18next'
import pieFullTanLogo from '_assets/pieFullTanLogo.svg'
import '_assets/styles/layouts.css'
import { ActionLink } from '_shared/ActionLink'
import { Row, Col } from 'antd'

export function AuthLayout({
  backgroundImageClass,
  contentComponent: ContentComponent
}) {
  const { t, i18n } = useTranslation()

  return (
    <Row className="h-screen">
      <Col
        lg={12}
        className={`h-screen bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <Col
        xs={24}
        lg={12}
        className="overflow-y-scroll mt-4 sm:mt-8 px-4 lg:px-8"
      >
        <Row gutter={{ xs: 16, lg: 32 }}>
          <Col
            xs={24}
            sm={{ span: 12, offset: 6 }}
            lg={{ span: 24, offset: 0 }}
          >
            <div className="text-right">
              <ActionLink
                onClick={() =>
                  i18n.changeLanguage(i18n.language === 'en' ? 'es' : 'en')
                }
                text={i18n.language === 'en' ? 'Español' : 'English'}
                classes="text-right no-underline p-0 h-auto"
              />
            </div>
            <div className="text-center lg:text-left">
              <img
                alt={t('pieforProvidersLogoAltText')}
                src={pieFullTanLogo}
                className="w-24 sm:w-48 mt-0 mb-10 sm:mb-16 lg:mb-12 mx-auto"
              />
              <ContentComponent />
            </div>
          </Col>
        </Row>
      </Col>
    </Row>
  )
}

AuthLayout.propTypes = {
  backgroundImageClass: PropTypes.string,
  contentComponent: PropTypes.func
}
