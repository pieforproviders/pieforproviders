import React from 'react'
import PropTypes from 'prop-types'
import { Divider, Grid, Typography } from 'antd'
import '_assets/styles/divider-overrides.css'

const { useBreakpoint } = Grid

export default function DashboardStats({ summaryData }) {
  const screens = useBreakpoint()
  return (
    <div className="grid grid-cols-2 mx-2 my-10 dashboard-stats sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6">
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
                style={{ height: '8.25rem', borderColor: '#BDBDBD' }}
                className="stats-divder sm:mr-4 m:mx-4"
                type="vertical"
              />
            )
          }
        }

        const renderStat = () => {
          return (
            <div className="w-full">
              {Array.isArray(stat) ? (
                stat.map((subStat, i) => {
                  return (
                    <div key={i} className="mt-2">
                      <p>
                        <Typography.Text>{subStat.title}</Typography.Text>
                        <Typography.Text className="ml-1 font-semibold text-blue2">
                          {subStat.stat}
                        </Typography.Text>
                      </p>
                      <Typography.Paragraph className="mt-1 text-xs">
                        {subStat.definition}
                      </Typography.Paragraph>
                      {i + 1 === stat.length ? null : <Divider />}
                    </div>
                  )
                })
              ) : (
                <div className="mt-2">
                  <p className="h-6 xs:whitespace-nowrap">
                    <Typography.Text>{stat.title}</Typography.Text>
                  </p>
                  <p>
                    <Typography.Text className="mb-6 text-blue2 h2-large">
                      {stat.stat}
                    </Typography.Text>
                  </p>
                  <Typography.Paragraph className="mt-5 mr-8 text-xs">
                    {stat.definition}
                  </Typography.Paragraph>
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
