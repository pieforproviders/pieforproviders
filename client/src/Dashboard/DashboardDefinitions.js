import React from 'react'
import PropTypes from 'prop-types'
import { Button, Collapse, Tag } from 'antd'
import { ArrowUpOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/tag-overrides.css'

export default function DashboardDefintions({ activeKey, setActiveKey }) {
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
          <div className="text-gray8 body-1">
            <div>
              <p className="h3-small text-black">{t('attendance')}</p>
            </div>
            <div className="my-4">
              <p>
                <Tag className={`red-tag custom-tag mr-0`}>
                  {t('exceededLimit')}
                </Tag>{' '}
                <span>{t('neExceededLimitDef')}</span>
              </p>
            </div>
            <div className="my-4">
              <Tag className={`green-tag custom-tag mr-0`}>{t('onTrack')}</Tag>
              <span>{t('neOnTrackDef')}</span>
            </div>
            <div className="my-4">
              <Tag className={`orange-tag custom-tag mr-0`}>{t('atRisk')}</Tag>
              <span>{t('neAtRiskDef')}</span>
            </div>
            {['fullDays', 'hours', 'hoursAttended', 'absences'].map((c, i) => (
              <div key={i} className="my-4">
                <span>
                  <span className="font-bold">{t(c)}</span>:{' '}
                  {t(`ne${c.charAt(0).toUpperCase() + c.slice(1)}Def`)}
                </span>
              </div>
            ))}
            <div>
              <p className="h3-small text-black">{t('revenue')}</p>
            </div>
            {['earnedRevenue', 'estimatedRevenue', 'transportationRevenue'].map(
              (c, i) => (
                <div key={i} className="my-4">
                  <span>
                    <span className="font-bold">{t(c)}</span>:{' '}
                    {t(`ne${c.charAt(0).toUpperCase() + c.slice(1)}Def`)}
                  </span>
                </div>
              )
            )}
            <footer className="flex justify-end" id="definitions">
              <a href="#top">
                <Button
                  onClick={setActiveKey}
                  className="eyebrow-large bg-primaryBlue text-white flex items-center no-underline toTop"
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
