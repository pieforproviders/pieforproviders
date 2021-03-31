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
            {[
              { name: 'exceededLimit', color: 'red' },
              { name: 'onTrack', color: 'green' },
              { name: 'atRisk', color: 'orange' },
              { name: 'aheadOfSchedule', color: 'green' }
            ].map((tag, i) => (
              <div key={i} className="my-4">
                <p>
                  <Tag className={`${tag.color}-tag custom-tag mr-0`}>
                    {t(tag.name)}
                  </Tag>{' '}
                  <span>
                    {t(
                      `ne${
                        tag.name.charAt(0).toUpperCase() + tag.name.slice(1)
                      }Def`
                    )}
                  </span>
                </p>
              </div>
            ))}
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
            {['earnedRevenue', 'estimatedRevenue', 'familyFee'].map((c, i) => (
              <div key={i} className="my-4">
                <span>
                  <span className="font-bold">{t(c)}</span>:{' '}
                  {t(`ne${c.charAt(0).toUpperCase() + c.slice(1)}Def`)}
                </span>
              </div>
            ))}
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
