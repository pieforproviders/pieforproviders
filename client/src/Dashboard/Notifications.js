import React from 'react'
import PropTypes from 'prop-types'
import { Button, Divider, List } from 'antd'
import dayjs from 'dayjs'
import { useTranslation } from 'react-i18next'
import { ExclamationCircleOutlined, MailOutlined } from '@ant-design/icons'
import { PIE_FOR_PROVIDERS_EMAIL } from '../constants'
import '_assets/styles/notification-list-overrides.css'

const Notifications = ({ messages, setShowModal, isModal = false }) => {
  const { t, i18n } = useTranslation()

  return (
    <List
      className={`notifications-list px-8 ${
        isModal ? 'my-4' : 'bg-blue4 mt-4 md:ml-4 md:w-2/3 xl:w-3/4'
      }`}
      header={
        <div className="text-lg font-semibold">
          <p>{`${t('notifications')} ${
            messages.length > 0 ? `(${messages.length})` : ''
          }`}</p>
          {isModal ? null : (
            <Divider style={{ borderTop: '1px solid #bdbdbd' }} />
          )}
        </div>
      }
      dataSource={isModal ? messages : messages.slice(0, 2)}
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
        !isModal && messages.length > 0 ? (
          <div className="bg-blue4">
            <Button type="link" onClick={() => setShowModal(true)}>
              <span className="underline text-base hover:text-blue2">
                {t('seeAllNotifications')}
              </span>
            </Button>
          </div>
        ) : null
      }
      renderItem={(item, index) => {
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
              {!isModal || (isModal && messages.length !== index + 1) ? (
                <Divider style={{ borderTop: '1px solid #bdbdbd' }} />
              ) : null}
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
  isModal: PropTypes.bool
}

export default Notifications
