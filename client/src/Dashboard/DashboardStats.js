/* eslint-disable no-debugger */
import React from 'react'
import PropTypes from 'prop-types'
import { Divider, Grid, List, Tooltip, Typography } from 'antd'
import { InfoCircleOutlined } from '@ant-design/icons'
import '_assets/styles/divider-overrides.css'

const { useBreakpoint } = Grid

export default function DashboardStats({ summaryData }) {
  const screens = useBreakpoint()

  if (
    (screens.xs && !screens.xl) ||
    (screens.sm && !screens.xl) ||
    (screens.md && screens.lg && !screens.xl)
  ) {
    return (
      <List
        className="bg-blue4 mt-4"
        dataSource={summaryData}
        renderItem={(item, index) => (
          <div className="m-5 flex flex-col justify-center items-center">
            {summaryData.length - 1 === index ? <Divider /> : null}
            <p className="h-6 xs:whitespace-nowrap mb-3">
              <Typography.Text className="text-lg flex items-center">
                {item.title}{' '}
                <Tooltip title={item.definition} className="ml-1">
                  <InfoCircleOutlined
                    data-testid="definition-tool-tip"
                    style={{ color: '#006C9E' }}
                  />
                </Tooltip>
              </Typography.Text>
            </p>
            <p>
              <Typography.Text className="text-blue2 h2-large text-5xl">
                {item.stat}
              </Typography.Text>
            </p>
          </div>
        )}
      />
    )
  }

  return (
    <div className="grid grid-cols-2 mt-4 md:mx-2 dashboard-stats md:w-1/3 xl:w-1/4 bg-blue4 xl:px-2 2xl:px-6">
      {summaryData.map((stat, i) => {
        const renderDivider = () => {
          if ((screens.sm || screens.xs) && !screens.md) {
            // eslint-disable-next-line no-unused-expressions
            return i % 2 === 0 ? (
              <Divider
                style={{ height: '8.25rem', borderColor: '#BDBDBD' }}
                className="m-2 stats-divider"
                type="vertical"
              />
            ) : null
          } else {
            // eslint-disable-next-line no-unused-expressions
            return summaryData.length === i + 1 ? null : (
              <Divider
                style={{ height: '10.25rem', borderColor: '#BDBDBD' }}
                className="stats-divder sm:mr-4 m:mx-4 mt-8"
                type="vertical"
              />
            )
          }
        }

        const renderStat = () => {
          return (
            <div className="w-full flex justify-center items-center">
              {Array.isArray(stat) ? (
                stat.map((subStat, i) => {
                  return (
                    <div key={i} className="mt-2">
                      <p>
                        <Typography.Text>
                          {subStat.title}
                          <Tooltip title={stat.definition} className="ml-1">
                            <InfoCircleOutlined
                              data-testid="definition-tool-tip"
                              style={{ color: '#006C9E' }}
                            />
                          </Tooltip>
                        </Typography.Text>
                        <Typography.Text className="ml-1 font-semibold text-blue2">
                          {subStat.stat}
                        </Typography.Text>
                      </p>
                      {i + 1 === stat.length ? null : <Divider />}
                    </div>
                  )
                })
              ) : (
                <div className="m-2">
                  <p className="h-6 xs:whitespace-nowrap mb-3">
                    <Typography.Text className="text-lg flex items-center">
                      {stat.title}{' '}
                      <Tooltip title={stat.definition} className="ml-1">
                        <InfoCircleOutlined
                          data-testid="definition-tool-tip"
                          style={{ color: '#006C9E' }}
                        />
                      </Tooltip>
                    </Typography.Text>
                  </p>
                  <p>
                    <Typography.Text className="mb-6 text-blue2 h2-large text-5xl">
                      {stat.stat}
                    </Typography.Text>
                  </p>
                </div>
              )}
            </div>
          )
        }

        return (
          <div key={i} className="flex dashboard-stat">
            {renderStat()}
            {renderDivider()}
          </div>
        )
      })}
    </div>
  )
}

DashboardStats.propTypes = {
  summaryData: PropTypes.array.isRequired
}
