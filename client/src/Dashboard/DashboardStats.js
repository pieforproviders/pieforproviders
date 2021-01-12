import React from 'react'
import PropTypes from 'prop-types'
import { Divider, Grid, Typography } from 'antd'
import '_assets/styles/divider-overrides.css'

const { useBreakpoint } = Grid

export default function DashboardStats({ summaryData }) {
  const screens = useBreakpoint()
  return (
    <div className="dashboard-stats grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6 mx-2 my-10">
      {summaryData.map((stat, i) => {
        const renderDivider = () => {
          if ((screens.sm || screens.xs) && !screens.md) {
            // eslint-disable-next-line no-unused-expressions
            return i % 2 === 0 ? (
              <Divider
                style={{ height: '8.5rem', borderColor: '#BDBDBD' }}
                className="stats-divider m-2"
                type="vertical"
              />
            ) : null
          } else {
            // eslint-disable-next-line no-unused-expressions
            return summaryData.length === i + 1 ? null : (
              <Divider
                style={{ height: '8.5rem', borderColor: '#BDBDBD' }}
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
                        <Typography.Text className="text-blue2 font-semibold ml-1">
                          {subStat.stat}
                        </Typography.Text>
                      </p>
                      <Typography.Paragraph className="text-xs mt-1">
                        {subStat.definition}
                      </Typography.Paragraph>
                      {i + 1 === stat.length ? null : <Divider />}
                    </div>
                  )
                })
              ) : (
                <div className="mt-2">
                  <p className="h-6 xs:whitespace-no-wrap">
                    <Typography.Text>{stat.title}</Typography.Text>
                  </p>
                  <p className="mt-2">
                    <Typography.Text className="text-blue2 text-3xl font-semibold mt-2 mb-6">
                      {stat.stat}
                    </Typography.Text>
                  </p>
                  <Typography.Paragraph className="text-xs mt-5">
                    {stat.definition}
                  </Typography.Paragraph>
                </div>
              )}
            </div>
          )
        }

        return (
          <div key={i} className="dashboard-stat flex">
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
