import React from 'react'
import PropTypes from 'prop-types'
import { Table } from 'antd'
import { columns } from './utils'

export function CasesImportReview({ kids }) {
  return (
    <div>
      <h1 className="sr-only">Review Imported Cases</h1>
      {kids.length > 0 && (
        <Table
          dataSource={kids}
          columns={columns}
          style={{ marginTop: '16px' }}
        />
      )}
    </div>
  )
}

CasesImportReview.defaultProps = {
  kids: []
}

CasesImportReview.propTypes = {
  kids: PropTypes.array
}
