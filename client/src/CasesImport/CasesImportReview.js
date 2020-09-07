import React from 'react'
import PropTypes from 'prop-types'
import { Table } from 'antd'
import { useTranslation } from 'react-i18next'
import { getColumns } from './utils'

export function CasesImportReview({ kids }) {
  const { t } = useTranslation()

  return (
    <div>
      <h1 className="sr-only">{t('reviewImportedCases')}</h1>
      {kids.length > 0 && (
        <div data-cy="cases-table">
          <Table
            dataSource={kids}
            columns={getColumns(t)}
            style={{ marginTop: '16px' }}
            id="cases-table"
          />
        </div>
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
