import React from 'react'
import PropTypes from 'prop-types'
import { Table, Tag } from 'antd'
import { useTranslation } from 'react-i18next'
import { attendanceCategories } from '_utils/constants'
import '_assets/styles/table-overrides.css'
import '_assets/styles/tag-overrides.css'

export default function DashboardTable({ tableData, userState }) {
  const { t } = useTranslation()

  const onHeaderCell = () => {
    return {
      style: {
        color: '#262626',
        fontWeight: 'bold'
      },
      role: 'columnheader'
    }
  }

  const columnSorter = (a, b, name) =>
    a[name] < b[name] ? -1 : a[name] > b[name] ? 1 : 0

  const renderAttendanceRate = attendanceRate => {
    const createTag = (color, text) => (
      <Tag className={`${color}-tag custom-tag`}>
        {`${attendanceRate.rate * 100}% - ${t(text)}`}
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

  const renderChild = child => {
    return child ?
    <div>
      <p className='text-lg'>{child.childName}</p>
      <p>{child.business+ ' ' + child.cNumber}</p>
    </div>
    : <></>
  }

  const generateColumns = columns => {
    return columns.map(({ name = '', children = [], ...options }) => {
      return {
        ...options,
        title: t(`${name}`),
        dataIndex: name,
        key: name,
        width: 150,
        onHeaderCell,
        children: generateColumns(children),
        sortDirections: ['descend', 'ascend']
      }
    })
  }

  const neColConfig = [
    { children: [{ name: 'child', render: renderChild } ]},
    {
      name: 'attendance',
      children: [
        { name: 'fullDays', sorter: (a, b) => columnSorter(a, b, 'fullDays') },
        { name: 'hours', sorter: (a, b) => columnSorter(a, b, 'hours') },
        { name: 'absences', sorter: (a, b) => columnSorter(a, b, 'absences') },
      ]
    },
    {
      name: 'revenue',
      children: [
        { name: 'earnedRevenue' },
        { name: 'estimatedRevenue' },
        { name: 'transportationRevenue' }
      ]
    }
  ]

  const defaultColConfig = [
    { name: 'childName', sorter: (a, b) => columnSorter(a, b, 'childName') },
    { name: 'cNumber', sorter: (a, b) => columnSorter(a, b, 'cNumber') },
    { name: 'business', sorter: (a, b) => columnSorter(a, b, 'business') },
    { name: 'attendanceRate', sorter: (a, b) => a.attendanceRate.rate - b.attendanceRate.rate, render: renderAttendanceRate },
    { name: 'guaranteedRevenue', sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue },
    { name: 'potentialRevenue', sorter: (a, b) => a.potentialRevenue - b.potentialRevenue},
    { name: 'maxApprovedRevenue', sorter: (a, b) => a.maxApprovedRevenue - b.maxApprovedRevenue }
  ]

  return (
    <Table
      dataSource={tableData}
      columns={userState === "NE" ? generateColumns(neColConfig) : generateColumns(defaultColConfig)}
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
