import React from 'react'
import PropTypes from 'prop-types'
import { Divider, List } from 'antd'
import dayjs from 'dayjs'
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
  }
]

const Notifications = ({ messages = mockMessages }) => (
  <List
    className="bg-blue4 px-8 md:ml-4 md:w-2/3 xl:w-3/4 mt-4"
    header={
      <div className="font-semibold text-lg">
        <p>{`NOTIFICATIONS ${
          messages.length > 0 ? `(${messages.length})` : ''
        }`}</p>
        <Divider />
      </div>
    }
    dataSource={messages}
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
            <p className="flex font-bold">No notifications right now</p>
            <p>We’ll let you know when there’s an update.</p>
          </div>
        </div>
      )
    }}
    renderItem={item => {
      return (
        <div className="flex items-start">
          <ExclamationCircleOutlined className="mr-3 text-red-500 text-xl" />
          <div className="inline-block mt-1">
            <div>
              <span className="font-bold">
                {item.first_name + ' ' + item.last_name + `'s `}
              </span>
              {'subsidy authorization expires on ' +
                dayjs(item.effective_on.slice(5, 16), 'DD MMM YYYY').format(
                  'MMM D'
                ) +
                '. ' +
                'Email the updated letter to '}
              <a
                className="underline"
                href={`mailto:${PIE_FOR_PROVIDERS_EMAIL}`}
              >
                {PIE_FOR_PROVIDERS_EMAIL + '.'}
              </a>
            </div>
            <div className="mt-1 text-gray-400">
              {dayjs(item.expiration_date.slice(5, 16), 'DD MMM YYYY').format(
                'MMM D, YYYY'
              ) || ''}
            </div>
            <Divider />
          </div>
        </div>
      )
    }}
  />
)

Notifications.propTypes = {
  messages: PropTypes.array
}

export default Notifications
