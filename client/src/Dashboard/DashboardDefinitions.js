import React, { useEffect, useState } from 'react'
import { Collapse } from 'antd'

const { Panel } = Collapse

export default function DashboardDefintions({ activeKey, setActiveKey }) {
  return (
    <Collapse ghost className="w-2/5 mt-8 bg-gray2" style={{border: '0px'}} activeKey={activeKey} onChange={() => setActiveKey(activeKey === 1 ? null : 1)}>
      <Panel header="Definitions" forceRender={true} key={1}>
        {
          <div id="fullDays"></div>
        }
      </Panel>
    </Collapse>
  )
}
