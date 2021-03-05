import React from 'react'
import PropTypes from 'prop-types'
import { Table, Tag } from 'antd'
import { useTranslation } from 'react-i18next'
import { attendanceCategories, fullDayCategories } from '_utils/constants'
import ellipse from '_assets/ellipse.svg'
import questionMark from '_assets/questionMark.svg'
import '_assets/styles/table-overrides.css'
import '_assets/styles/tag-overrides.css'

const currencyFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  minimumFractionDigits: 0
})

export default function DashboardTable({ tableData, userState, setActiveKey }) {
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
      case attendanceCategories.AHEADOFSCHEDULE:
        return createTag('green', 'aheadOfSchedule')
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
          <p className="mb-1">{fullday.text.replace('of', t('of'))}</p>
          <Tag className={`${color}-tag custom-tag`}>{t(text)}</Tag>
        </div>
      )
    }
    switch (fullday.tag) {
      case fullDayCategories.AHEADOFSCHEDULE:
        return renderCell('green', 'aheadOfSchedule')
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
      const hasDefinition = ['attendance', 'revenue']
      return {
        // eslint-disable-next-line react/display-name
        title: () =>
          hasDefinition.includes(name) ? (
            <div className="flex">
              {t(`${name}`)}
              <a
                href={'#definitions'}
                onClick={() => setActiveKey(name)}
                id={name}
              >
                <img
                  className={`ml-1`}
                  src={questionMark}
                  alt="question mark"
                />
              </a>
            </div>
          ) : (
            t(`${name}`)
          ),
        dataIndex: name,
        key: name,
        width: 200,
        onHeaderCell,
        children: generateColumns(children),
        sortDirections: ['descend', 'ascend'],
        ...options
      }
    })
  }

  function renderDollarAmount(num) {
    return <div>{currencyFormatter.format(num)}</div>
  }

  const replaceText = (text, translation) => (
    <div>{text.replace(translation, t(translation))}</div>
  )

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
              a.fullDays.text.match(/^\d+/)[0] -
              b.fullDays.text.match(/^\d+/)[0],
            render: renderFullDays
          },
          {
            name: 'hours',
            sorter: (a, b) =>
              a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
            render: text => replaceText(text, 'of')
          },
          {
            name: 'absences',
            sorter: (a, b) =>
              a.absences.match(/^\d+/)[0] - b.absences.match(/^\d+/)[0],
            render: text => replaceText(text, 'of')
          }
        ]
      },
      {
        name: 'revenue',
        children: [
          {
            name: 'earnedRevenue',
            sorter: (a, b) => a.earnedRevenue - b.earnedRevenue,
            render: renderDollarAmount
          },
          {
            name: 'estimatedRevenue',
            sorter: (a, b) => {
              return a.estimatedRevenue - b.estimatedRevenue
            },
            render: renderDollarAmount
          },
          {
            name: 'transportationRevenue',
            sorter: (a, b) =>
              a.transportationRevenue.match(/([0-9]+.[0-9]{2})/)[0] -
              b.transportationRevenue.match(/([0-9]+.[0-9]{2})/)[0],
            render: text => replaceText(text, 'trips')
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
        sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue,
        render: renderDollarAmount
      },
      {
        name: 'potentialRevenue',
        sorter: (a, b) => a.potentialRevenue - b.potentialRevenue,
        render: renderDollarAmount
      },
      {
        name: 'maxApprovedRevenue',
        sorter: (a, b) => a.maxApprovedRevenue - b.maxApprovedRevenue,
        render: renderDollarAmount
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
      locale={{
        triggerDesc: t('sortDesc'),
        triggerAsc: t('sortAsc'),
        cancelSort: t('sortCancel')
      }}
    />
  )
}

DashboardTable.propTypes = {
  tableData: PropTypes.array.isRequired,
  userState: PropTypes.string,
  setActiveKey: PropTypes.func.isRequired
}
