import React from 'react'
import PropTypes from 'prop-types'
import { Table, Tag } from 'antd'
import { useTranslation } from 'react-i18next'
import { attendanceCategories, fullDayCategories } from '_utils/constants'
import ellipse from '_assets/ellipse.svg'
import '_assets/styles/table-overrides.css'
import '_assets/styles/tag-overrides.css'

export default function DashboardTable({ tableData, userState }) {
  const { t } = useTranslation()
  const columnSorter = (a, b) => (a < b ? -1 : a > b ? 1 : 0)
  const onHeaderCell = () => {
    return {
      style: {
        color: '#262626',
        fontWeight: 'bold'
      },
      role: 'columnheader'
    }
  }

  const renderAttendanceRate = attendanceRate => {
    const createTag = (color, text) => (
      <Tag className={`${color}-tag custom-tag`}>
        {`${(attendanceRate.rate * 100).toFixed(1)}% - ${t(text)}`}
      </Tag>
    )

    switch (attendanceRate.riskCategory) {
      case attendanceCategories.ONTRACK:
        return createTag('green', 'onTrack')
      case attendanceCategories.SUREBET:
        return createTag('green', 'sureBet')
      case attendanceCategories.ATRISK:
        return createTag('orange', 'atRisk')
      case attendanceCategories.NOTMET:
        return createTag('orange', 'notMet')
      case attendanceCategories.NOTENOUGHINFO:
      default:
        return createTag('grey', 'notEnoughInfo')
    }
  }

  const renderFullDays = fullday => {
    const renderCell = (color, text) => {
      return (
        <div className="-mb-4">
          <p className="mb-1">{`${fullday.text}`}</p>
          <Tag className={`${color}-tag custom-tag`}>{`${
            t(text).charAt(0).toUpperCase() + t(text).slice(1)
          }`}</Tag>
        </div>
      )
    }

    switch (fullday.tag) {
      case fullDayCategories.ONTRACK:
        return renderCell('green', 'onTrack')
      case fullDayCategories.ATRISK:
        return renderCell('orange', 'atRisk')
      case fullDayCategories.EXCEEDEDLIMIT:
        return renderCell('red', 'exceededLimit')
      default:
        return renderCell('grey', 'notEnoughInfo')
    }
  }

  const renderChild = child => {
    return child ? (
      <div>
        <p className="text-lg mb-1">{child.childName}</p>
        <p className="flex flex-wrap mt-0.5">
          {child.business} <img className="mx-1" alt="ellipse" src={ellipse} />{' '}
          {child.cNumber}
        </p>
      </div>
    ) : (
      <></>
    )
  }

  const generateColumns = columns => {
    return columns.map(({ name = '', children = [], ...options }) => {
      return {
        title: t(`${name}`),
        dataIndex: name,
        key: name,
        width: 150,
        onHeaderCell,
        children: generateColumns(children),
        sortDirections: ['descend', 'ascend'],
        ...options
      }
    })
  }

  const columnConfig = {
    ne: [
      {
        children: [
          {
            name: 'child',
            render: renderChild,
            width: 250,
            sorter: (a, b) =>
              columnSorter(
                a.child.childName.match(/([A-zÀ-ú])+$/)[0],
                b.child.childName.match(/([A-zÀ-ú])+$/)[0]
              )
          }
        ]
      },
      {
        name: 'attendance',
        children: [
          {
            name: 'fullDays',
            sorter: (a, b) =>
              a.fullDays.match(/^\d+/)[0] - b.fullDays.match(/^\d+/)[0],
            render: renderFullDays
          },
          {
            name: 'hours',
            sorter: (a, b) =>
              a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0]
          },
          {
            name: 'absences',
            sorter: (a, b) =>
              a.absences.match(/^\d+/)[0] - b.absences.match(/^\d+/)[0]
          }
        ]
      },
      {
        name: 'revenue',
        children: [
          {
            name: 'earnedRevenue',
            sorter: (a, b) => a.earnedRevenue - b.earnedRevenue
          },
          {
            name: 'estimatedRevenue',
            sorter: (a, b) => a.estimatedRevenue - b.estimatedRevenue
          },
          {
            name: 'transportationRevenue',
            sorter: (a, b) =>
              a.transportationRevenue.match(/([0-9]+.[0-9]{2})/)[0] -
              b.transportationRevenue.match(/([0-9]+.[0-9]{2})/)[0]
          }
        ]
      }
    ],
    default: [
      {
        name: 'childName',
        sorter: (a, b) => columnSorter(a.childName, b.childName)
      },
      { name: 'cNumber', sorter: (a, b) => columnSorter(a.cNumber, b.cNumber) },
      {
        name: 'business',
        sorter: (a, b) => columnSorter(a.business, b.business)
      },
      {
        name: 'attendanceRate',
        sorter: (a, b) => a.attendanceRate.rate - b.attendanceRate.rate,
        render: renderAttendanceRate
      },
      {
        name: 'guaranteedRevenue',
        sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue
      },
      {
        name: 'potentialRevenue',
        sorter: (a, b) => a.potentialRevenue - b.potentialRevenue
      },
      {
        name: 'maxApprovedRevenue',
        sorter: (a, b) => a.maxApprovedRevenue - b.maxApprovedRevenue
      }
    ]
  }

  return (
    <Table
      dataSource={tableData}
      columns={
        userState === 'NE'
          ? generateColumns(columnConfig['ne'])
          : generateColumns(columnConfig['default'])
      }
      bordered={true}
      size={'medium'}
      pagination={false}
      sticky
      className="dashboard-table"
      scroll={{ x: 'max-content' }}
    />
  )
}

DashboardTable.propTypes = {
  tableData: PropTypes.array.isRequired,
  userState: PropTypes.string
}
