import React from 'react'
import PropTypes from 'prop-types'
import { Collapse, Divider } from 'antd'
import { ExclamationCircleOutlined } from '@ant-design/icons'

const { Panel } = Collapse

const mockMessages = [
  {
    message:
      "Eleanor Pena's subsidy approval is expiring on May 31st Email the updated letter to team@pieforproviders.com",
    date: 'May 1, 2022'
  },
  {
    message:
      "Jenny Wilson's subsidy approval is expiring on May 31st Email the updated letter to team@pieforproviders.com",
    date: 'May 1, 2022'
  }
]

const Notifications = ({ messages = mockMessages }) => (
  <Collapse>
    <Panel header={`NOTIFICATIONS (${messages.length})`}>
      <div>
        {messages.map(({ message, date }, index) => (
          <div key={index} className="flex items-start">
            <ExclamationCircleOutlined className="mr-3 text-red-500 text-xl" />
            <div className="inline-block mt-1">
              <div>{message}</div>
              <div className="mt-1 text-gray-400">{date}</div>
              <Divider />
            </div>
          </div>
        ))}
      </div>
    </Panel>
  </Collapse>
)

Notifications.propTypes = {
  messages: PropTypes.array
}

export default Notifications
