import React from 'react'
import PropTypes from 'prop-types'
import { Button, Collapse, Tag, Typography } from 'antd'
import { ArrowUpOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/tag-overrides.css'
import '_assets/styles/title-overrides.css'

export default function DashboardDefintions({ activeKey, setActiveKey }) {
  const { Title } = Typography
  const { Panel } = Collapse
  const { t } = useTranslation()

  return (
    <Collapse
      ghost
      className="lg:w-3/5 md:w-1/2 sm:w-full mt-8 bg-gray2"
      style={{ border: '0px' }}
      activeKey={activeKey}
      onChange={setActiveKey}
    >
      <Panel
        header={<div className="text-black">{t('definitions')}</div>}
        forceRender={true}
        key={1}
      >
        {
          <div className="text-gray8">
            <div>
              <Title level={4} className="definitions-title">
                {t('attendance')}
              </Title>
            </div>
            <div className="my-4">
              <p>
                <Tag className={`green-tag custom-tag mr-0`}>
                  {t('exceededLimit')}
                </Tag>{' '}
                <span>{t('exceededLimitDef')}</span>
              </p>
            </div>
            <div className="my-4">
              <Tag className={`green-tag custom-tag mr-0`}>{t('onTrack')}</Tag>
              <span>{t('onTrackDef')}</span>
            </div>
            <div className="my-4">
              <Tag className={`orange-tag custom-tag mr-0`}>{t('atRisk')}</Tag>
              <span>{t('atRiskDef')}</span>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('fullDays')}</span>:{' '}
                {t('fullDaysDef')}
              </span>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('hours')}</span>: {t('hoursDef')}
              </span>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('absences')}</span>:{' '}
                {t('absencesDef')}
              </span>
            </div>
            <div>
              <Title level={4} className="definitions-title">
                {t('revenue')}
              </Title>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('earnedRevenue')}</span>:{' '}
                {t('earnedRevenueDef2')}
              </span>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('estimatedRevenue')}</span>:{' '}
                {t('estimatedRevenueDef2')}
              </span>
            </div>
            <div className="my-4">
              <span>
                <span className="font-bold">{t('transportationRevenue')}</span>:{' '}
                {t('transportationRevenueDef')}
              </span>
            </div>
            <footer className="flex justify-end" id="definitions">
              <a href="#top">
                <Button
                  onClick={setActiveKey}
                  className="bg-primaryBlue text-white flex items-center no-underline toTop"
                  size="large"
                >
                  {t('backToTop')}
                  <ArrowUpOutlined className="font-bold" />
                </Button>
              </a>
            </footer>
          </div>
        }
      </Panel>
    </Collapse>
  )
}

DashboardDefintions.propTypes = {
  activeKey: PropTypes.number,
  setActiveKey: PropTypes.func
}
