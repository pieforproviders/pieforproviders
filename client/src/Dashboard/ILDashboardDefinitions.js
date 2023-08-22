import React from 'react'
import PropTypes from 'prop-types'
import { Button, Collapse, Tag } from 'antd'
import { ArrowUpOutlined } from '@ant-design/icons'
import { useTranslation } from 'react-i18next'
import '_assets/styles/tag-overrides.css'

export default function ILDashboardDefinitions({ activeKey, setActiveKey }) {
  const { Panel } = Collapse
  const { t } = useTranslation()
  const titleWithDescription = {
    display: 'flex',
    flex: 1,
    justifyContent: 'space-between',
    flexDirection: 'row',
    alignItems: 'baseline'
  }

  return (
    <Collapse
      ghost
      className="mt-8 lg:w-3/5 md:w-1/2 sm:w-full bg-gray2"
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
            <div style={titleWithDescription}>
              <p>
                <span className="text-black h3-small">
                  {t('attendanceRate')}:
                </span>{' '}
                <span>{t('ilAttendanceRateDef')}</span>
              </p>
            </div>
            {[
              { name: 'atRisk', color: 'orange' },
              { name: 'onTrack', color: 'green' }
            ].map((tag, i) => (
              <div key={i} className="my-4">
                <p>
                  <Tag className={`${tag.color}-tag custom-tag mr-0`}>
                    {t(tag.name)}
                  </Tag>{' '}
                  <span>
                    {t(
                      `il${
                        tag.name.charAt(0).toUpperCase() + tag.name.slice(1)
                      }Def`
                    )}
                  </span>
                </p>
              </div>
            ))}
            <div style={titleWithDescription}>
              <p>
                <span className="text-black h3-small">
                  {t('earnedRevenue')}:
                </span>{' '}
                <span>{t('ilEarnedRevenueDef')}</span>
              </p>
            </div>
            <br />
            <div style={titleWithDescription}>
              <p>
                <span className="text-black h3-small">
                  {t('authorizedPeriod')}:
                </span>{' '}
                <span>{t('ilAuthorizedPeriodDef')}</span>
              </p>
            </div>
            <footer className="flex justify-end" id="definitions">
              <a href="#top">
                <Button
                  onClick={setActiveKey}
                  className="flex items-center text-white no-underline eyebrow-large bg-primaryBlue toTop"
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

ILDashboardDefinitions.propTypes = {
  activeKey: PropTypes.number,
  setActiveKey: PropTypes.func
}
