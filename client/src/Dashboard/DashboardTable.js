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
  // NOTE: prop user state will be used to configure table columns
  // configuation for table columns
  const columns = [
    {
      title: t('childName'),
      dataIndex: 'childName',
      key: 'childName',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'childName'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('caseNumberLowercase'),
      dataIndex: 'caseNumber',
      key: 'caseNumber',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'caseNumber'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('business'),
      dataIndex: 'business',
      key: 'business',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'business'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('attendanceRate'),
      dataIndex: 'attendanceRate',
      key: 'attendanceRate',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => a.attendanceRate.rate - b.attendanceRate.rate,
      sortDirections: ['descend', 'ascend'],
      render: attendanceRate => {
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
    },
    {
      title: t('guaranteedRevenue'),
      dataIndex: 'guaranteedRevenue',
      key: 'guaranteedRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue,
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('potentialRevenue'),
      dataIndex: 'potentialRevenue',
      key: 'potentialRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => a.potentialRevenue - b.potentialRevenue,
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('maxApprovedRevenue'),
      dataIndex: 'maxRevenue',
      key: 'maxRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => a.maxRevenue - b.maxRevenue,
      sortDirections: ['descend', 'ascend']
    }
  ]

  return (
    <Table
      dataSource={tableData}
      columns={columns}
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
