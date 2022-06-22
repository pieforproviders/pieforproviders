import React from 'react'
import PropTypes from 'prop-types'
import { Button, Divider, List } from 'antd'
import dayjs from 'dayjs'
import { useTranslation } from 'react-i18next'
import { ExclamationCircleOutlined, MailOutlined } from '@ant-design/icons'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'

const mockMessages = [
  {
    first_name: 'Jasveen',
    last_name: 'Khirwar',
    effective_on: 'Mon, 06 Jun 2022 18:01:18.814736000 UTC +00:00',
    expiration_date: 'Mon, 01 Jun 2022 18:01:18.814736000 UTC +00:00'
  },
  {
    first_name: 'Jane',
    last_name: 'Queen',
    effective_on: 'Mon, 06 Jun 2022 18:01:18.814736000 UTC +00:00',
    expiration_date: 'Mon, 01 Jun 2022 18:01:18.814736000 UTC +00:00'
  },
  {
    first_name: 'Snoop',
    last_name: 'Queen',
    effective_on: 'Mon, 06 Jun 2022 18:01:18.814736000 UTC +00:00',
    expiration_date: 'Mon, 01 Jun 2022 18:01:18.814736000 UTC +00:00'
  }
]

const Notifications = ({ setShowModal, showFooter = false }) => {
  const { t, i18n } = useTranslation()

  return (
    <List
      className="px-8 mt-4 bg-blue4 md:ml-4 md:w-2/3 xl:w-3/4"
      header={
        <div className="text-lg font-semibold">
          <p>{`${t('notifications')} ${
            mockMessages.length > 0 ? `(${mockMessages.length})` : ''
          }`}</p>
          <Divider />
        </div>
      }
      dataSource={showFooter ? mockMessages.slice(0, 2) : mockMessages}
      locale={{
        emptyText: (
          <div className="flex">
            <MailOutlined
              style={{
                color: '#676767',
                fontSize: '2.25rem'
              }}
            />
            <div className="ml-3 text-gray4">
              <p className="flex font-bold">{t('noNotifications1')}</p>
              <p>{t('noNotifications2')}</p>
            </div>
          </div>
        )
      }}
      footer={
        showFooter ? (
          <div>
            <Button type="link" onClick={() => setShowModal(true)}>
              <span className="underline">See all notifications here</span>
            </Button>
          </div>
        ) : null
      }
      renderItem={item => {
        const effectiveDate = dayjs(item.created_at)
        const expirationDate = dayjs(item.expires_on)
        return (
          <div className="flex items-start">
            <ExclamationCircleOutlined className="mr-3 text-xl text-red-500" />
            <div className="inline-block mt-1">
              <div>
                {i18n.language === 'en' ? (
                  <>
                    <span className="font-bold">
                      {item.first_name + ' ' + item.last_name + `'s `}
                    </span>
                    {t('subsidyAuth') +
                      ' ' +
                      t('subAuthExpires') +
                      expirationDate.format('MMM D') +
                      '. '}
                  </>
                ) : (
                  <>
                    {t('subsidyAuth')}
                    <span className="font-bold">
                      {item.first_name + ' ' + item.last_name + ' '}
                    </span>
                    {t('subAuthExpires') +
                      expirationDate.format('D') +
                      ' de ' +
                      expirationDate.format('MMM') +
                      '. '}
                  </>
                )}
                {t('emailTo')}
                <a
                  className="underline"
                  href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}
                >
                  {PIE_FOR_PROVIDERS_EMAIL + '.'}
                </a>
              </div>
              {i18n.language === 'en' ? (
                <div className="mt-1 text-gray-400">
                  {effectiveDate.format('MMM D, YYYY') || ''}
                </div>
              ) : (
                <div className="mt-1 text-gray-400">
                  {effectiveDate.format('D') +
                    ' de ' +
                    effectiveDate.format('MMM, YYYY')}
                </div>
              )}
              <Divider />
            </div>
          </div>
        )
      }}
    />
  )
}

Notifications.propTypes = {
  messages: PropTypes.array,
  setShowModal: PropTypes.func,
  showFooter: PropTypes.bool
}

export default Notifications
