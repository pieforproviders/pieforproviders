import React, { useState } from 'react'
import { Alert, Typography } from 'antd'
import { useTranslation } from 'react-i18next'
import { CasesImportReview } from './CasesImportReview'
import { parserTypes, getColumns, randomHash } from './utils'

const { Title } = Typography

export function CasesImport() {
  const [kids, setKids] = useState([])
  const [error, setError] = useState('')
  const { t } = useTranslation()

  const columns = getColumns(t)

  const onFileChange = e => {
    setError('')

    const [file] = e.target.files
    const { type } = file
    if (!(type in parserTypes)) {
      setKids([])
      setError(t('uploadCasesInvalidFileFormat'))
      return
    }

    const reader = new FileReader()
    const readAsBinaryString = !!reader.readAsBinaryString
    reader.onload = e => {
      const { data } = parserTypes[type].parse(e.target.result, {
        readAsBinaryString
      })
      // Skip the instruction, header and column description rows
      const rows = data.slice(3)
      const kids = rows
        .map(row =>
          row.reduce(
            (acc, item, index) => ({
              ...acc,
              [columns[index]?.key]: item
            }),
            {}
          )
        )
        .map(kid => ({
          ...kid,
          key: randomHash([kid.firstName, kid.lastName, kid.dateOfBirth])
        }))
        .filter(kid => kid.firstName && kid.lastName && kid.dateOfBirth)
      setKids(kids)
    }

    if (readAsBinaryString) {
      return reader.readAsBinaryString(file)
    }

    reader.readAsArrayBuffer(file)
  }

  return (
    <div>
      <Title>{t('uploadCases')}</Title>
      {error && (
        <Alert
          message={error}
          type="error"
          showIcon
          style={{ marginBottom: '16px' }}
        />
      )}
      <input type="file" accept=".csv,.xls,.xlsx" onChange={onFileChange} />
      <CasesImportReview kids={kids} />
    </div>
  )
}
