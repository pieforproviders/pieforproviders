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
        md={12}
        className={`h-screen bg-no-repeat bg-cover ${backgroundImageClass}`}
      />
      <Col
        xs={24}
        md={12}
        className="overflow-y-scroll mt-4 xs:mt-8 px-4 md:px-8"
      >
        <Row gutter={{ xs: 16, md: 32 }}>
          <Col
            xs={24}
            sm={{ span: 12, offset: 6 }}
            md={{ span: 24, offset: 0 }}
          >
            <header className="text-right">
              <ActionLink
                onClick={() =>
                  i18n.changeLanguage(i18n.language === 'en' ? 'es' : 'en')
                }
                text={i18n.language === 'en' ? 'Español' : 'English'}
                classes="text-right no-underline p-0 h-auto"
              />
              <img
                alt={t('pieforProvidersLogoAltText')}
                src={pieFullTanLogo}
                className="w-24 xs:w-48 mt-0 mb-10 xs:mb-16 md:mb-12 mx-auto"
              />
            </header>
            <div className="text-center md:text-left">
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
